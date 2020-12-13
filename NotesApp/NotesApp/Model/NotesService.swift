//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    private let fileManager: FileManager
    private let path: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let userDefaults = UserDefaults.standard
    private var pinnedNotesKey = "pinnedNotesKey"
    
    init() {
        fileManager = FileManager()
        path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        var notes: [Note] = []
        var pinnedNotes: [Note] = []
        let pinnedNotesId = userDefaults.stringArray(forKey: pinnedNotesKey) ?? [String]()
        do {
            for content in try fileManager.contentsOfDirectory(atPath: path.path) {
                let filePath = path.appendingPathComponent(content)
                guard let data = fileManager.contents(atPath: filePath.path) else { return }
                let note = decodeNote(data: data)
                if pinnedNotesId.contains(note.id.uuidString) {
                    pinnedNotes.append(note)
                } else {
                    notes.append(note)
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
        pinnedNotes = pinnedNotes.sorted(by: { n1, n2 in
            return n1.dateModified! > n2.dateModified!
        })
        notes = notes.sorted(by: { n1, n2 in
            return n1.dateModified! > n2.dateModified!
        })
        completionHandler(.success(pinnedNotes + notes))
    }

    /// Создаёт новую заметку, если note.dateModified== nil; Редактирует существующую заметку, если note.dateModified != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if note.dateModified != nil {
            var editedNote = note
            editedNote.dateModified = Date()
            let pinned = checkOnPin(note: note)
            
            delete(note: note) { result in
                switch result {
                case .success():
                    print("Succes")
                case .failure(let error):
                    print(error)
                }
            }
            
            if pinned {
                pinNote(note: editedNote)
            }
            
            let pathToSave = path.appendingPathComponent("\(editedNote.id).json")
            let data = encodeNote(note: editedNote)
            fileManager.createFile(atPath: pathToSave.path, contents: data, attributes: nil)
        } else {
            var newNote = note
            newNote.dateModified = Date()
            
            let pathToSave = path.appendingPathComponent("\(note.id).json")
            let data = encodeNote(note: newNote)
            fileManager.createFile(atPath: pathToSave.path, contents: data, attributes: nil)
        }
    }

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let pathToRemove = path.appendingPathComponent("\(note.id).json")
        do {
            try fileManager.removeItem(atPath: pathToRemove.path)
            
            var pinnedNotesArray = UserDefaults.standard.stringArray(forKey: pinnedNotesKey) ?? [String]()
            if (pinnedNotesArray.contains(note.id.uuidString)) {
                pinnedNotesArray.removeAll { uuidString in
                    return uuidString == note.id.uuidString
                }
                userDefaults.setValue(pinnedNotesArray, forKey: pinnedNotesKey)
            }
        } catch {
            return completionHandler(.failure(error))
        }
    }
    
    func pinNote(note: Note) {
        var pinnedNotesArray = UserDefaults.standard.stringArray(forKey: pinnedNotesKey) ?? [String]()
        pinnedNotesArray.append(note.id.uuidString)
        userDefaults.setValue(pinnedNotesArray, forKey: pinnedNotesKey)
    }
    
    func unpinNote(note: Note) {
        var pinnedNotesArray = UserDefaults.standard.stringArray(forKey: pinnedNotesKey) ?? [String]()
        if (pinnedNotesArray.contains(note.id.uuidString)) {
            pinnedNotesArray.removeAll { uuidString in
                return uuidString == note.id.uuidString
            }
            userDefaults.setValue(pinnedNotesArray, forKey: pinnedNotesKey)
        }
    }
    
    private func encodeNote(note: Note) -> Data {
        do {
            let data = try self.encoder.encode(note)
            return data
        } catch {
            fatalError("Cannot encode note")
        }
    }
    
    private func decodeNote(data: Data) -> Note {
        do {
            let note = try self.decoder.decode(Note.self, from: data)
            return note
        } catch {
            fatalError("Cannot decode data")
        }
    }
    
    private func checkOnPin(note: Note) -> Bool {
        let pinnedNotesArray = UserDefaults.standard.stringArray(forKey: pinnedNotesKey) ?? [String]()
        
        return pinnedNotesArray.contains(note.id.uuidString)
    }
}
