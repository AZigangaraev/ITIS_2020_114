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
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], NotesServiceError>) -> Void) {
        let result: Result<[Note], NotesServiceError>
        var notes: [Note] = []
        defer {
            completionHandler(result)
        }
        guard let pathDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return result = .failure(.pathCreation)
        }
        do {
            let arrayOfFilenames = try fileManager.contentsOfDirectory(atPath: pathDocumentDirectory.path)
            for filename in arrayOfFilenames {
                let data = try Data(contentsOf: pathDocumentDirectory.appendingPathComponent(filename))
                let note = try decoder.decode(Note.self, from: data)
                notes.append(note)
            }
            notes.sort {
                if let dateFirst = $0.dateModified, let dateSecond = $1.dateModified {
                    return dateFirst.compare(dateSecond) == .orderedDescending
                }
                return false
            }
            return result = .success(notes)
        }
        catch {
            return result = .failure(.decoderError(error))
        }
        
    }
    
    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, NotesServiceError>) -> Void) {
        let result: Result<Void, NotesServiceError>
        var currentNote = note
        defer {
            completionHandler(result)
        }
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return result = .failure(.pathCreation)
        }
        let notePath = path.appendingPathComponent("\(currentNote.id.uuidString).json")
        if currentNote.dateModified == nil {
            do {
                currentNote.dateModified = Date()
                let data = try encoder.encode(currentNote)
                guard fileManager.createFile(atPath: notePath.path, contents: data) else {
                    return result = .failure(.fileCreation)
                }
                return result = .success(())
            } catch {
                return result = .failure(.encoderError(error))
            }
        } else {
            return result = .success(())
        }
    }
    
    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, NotesServiceError>) -> Void) {
        let result: Result<Void, NotesServiceError>
        defer {
            completionHandler(result)
        }
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return result = .failure(.pathCreation)
        }
        let notePath = path.appendingPathComponent("\(note.id.uuidString).json")
        do {
            try fileManager.removeItem(at: notePath)
            return result = .success(())
        } catch {
            return result = .failure(.deleteError(error))
        }
    }
}
