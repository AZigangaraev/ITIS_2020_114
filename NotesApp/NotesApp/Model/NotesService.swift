//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

enum NotesServiceError: Error {
    case encoderError(Error)
    case decoderError(Error)
    case deleteError(Error)
    case noData
    case fileCreation
    case pathCreation
}

class NotesService {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    private let namePinnedArray = "pinnedNotesArray"
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], NotesServiceError>) -> Void) {
        var notes: [Note] = []
        var pinnedNotes: [Note] = []
        let pinnedNotesUUID: [String] = getPinnedNotes()
        guard let pathDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return completionHandler(.failure(.pathCreation))
        }
        do {
            let arrayOfFilenames = try fileManager.contentsOfDirectory(atPath: pathDocumentDirectory.path)
            for filename in arrayOfFilenames {
                let data = try Data(contentsOf: pathDocumentDirectory.appendingPathComponent(filename))
                let note = try decoder.decode(Note.self, from: data)
                if (pinnedNotesUUID.contains(note.id.uuidString)) {
                    pinnedNotes.append(note)
                } else {
                    notes.append(note)
                }
            }
            pinnedNotes.sort {
                if let dateFirst = $0.dateModified, let dateSecond = $1.dateModified {
                    return dateFirst.compare(dateSecond) == .orderedDescending
                }
                return false
            }
            notes.sort {
                if let dateFirst = $0.dateModified, let dateSecond = $1.dateModified {
                    return dateFirst.compare(dateSecond) == .orderedDescending
                }
                return false
            }
            completionHandler(.success(pinnedNotes + notes))
        }
        catch {
            completionHandler(.failure(.decoderError(error)))
        }
    }
    
    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, NotesServiceError>) -> Void) {
        var currentNote = note
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return completionHandler(.failure(.pathCreation))
        }
        let notePath = path.appendingPathComponent("\(currentNote.id.uuidString).json")
        if note.dateModified != nil {
            delete(note: note) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(()): break
                }
            }
        }
        do {
            currentNote.dateModified = Date()
            let data = try encoder.encode(currentNote)
            guard fileManager.createFile(atPath: notePath.path, contents: data) else {
                return completionHandler(.failure(.fileCreation))
            }
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(.encoderError(error)))
        }
    }
    
    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, NotesServiceError>) -> Void) {
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return completionHandler(.failure(.pathCreation))
        }
        let notePath = path.appendingPathComponent("\(note.id.uuidString).json")
        do {
            try fileManager.removeItem(at: notePath)
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(.deleteError(error)))
        }
    }
    
    private func getPinnedNotes() -> [String] {
        return userDefaults.array(forKey: namePinnedArray) as? [String] ?? []
    }
}
