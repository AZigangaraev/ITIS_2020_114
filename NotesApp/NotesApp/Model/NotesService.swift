//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

enum NotesError: Error {
    case encodeError(Error)
    case decodeError(Error)
    case deleteError(Error)
}

class NotesService {
    let fileManager = FileManager.default
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let encode = JSONEncoder()
    let decode = JSONDecoder()
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], NotesError>) -> Void) {
        var notes: [Note] = []
        var sortedNotes: [Note] = []
        let format = DateFormatter()
        format.dateFormat = "HH:mm E, d MMM y"
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for content in directoryContent {
                let noteData = try Data(contentsOf: content)
                let decodedNote = try decode.decode(Note.self, from: noteData)
                notes.append(decodedNote)
            }
            
            sortedNotes = notes.sorted{ $0.dateModified! > $1.dateModified! }
            return completionHandler(.success(sortedNotes))
        }
        catch {
            return completionHandler(.failure(.encodeError(error)))
        }
    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, NotesError>) -> Void) {
        var newNote = note
        
        do {
            newNote.dateModified = Date()
            let noteData = try encode.encode(newNote)
            let newNotePath = path.appendingPathComponent("\(newNote.id.uuid).json")
            fileManager.createFile(atPath: newNotePath.path, contents: noteData)
            completionHandler(.success(()))
            
        } catch {
            completionHandler(.failure(.encodeError(error)))
        }
        
        
    }
    

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, NotesError>) -> Void) {
        let deleteNote = note
        let pathToDelete = path.appendingPathComponent("\(deleteNote.id.uuid).json")
        do {
            try fileManager.removeItem(atPath: pathToDelete.path)
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(.deleteError(error)))
        }
    }
}
