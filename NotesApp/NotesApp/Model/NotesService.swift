//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

enum NotesServiceError : Error {
    case cannotFindDirectory
    case encode(Error)
    case decode(Error)
    case writing(Error)
    case deleting
    case convertingFromString
    case readingDirectory(Error)
    case badData
}

class NotesService {
    
    private let responseQueue: DispatchQueue
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager = FileManager()
    
    init(responseQueue: DispatchQueue) {
        self.responseQueue = responseQueue
    }
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], NotesServiceError>) -> Void) {
        let result: Result<[Note], NotesServiceError>
        defer {
            completionHandler(result)
        }
        
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return result = .failure(.cannotFindDirectory)
        }
        
        do {
            var notes: [Note] = []
            let items = try fileManager.contentsOfDirectory(atPath: documentDirectory.path)
            for item in items {
                let filePath = documentDirectory.appendingPathComponent(item)

                guard let data = fileManager.contents(atPath: filePath.path) else {
                    return result = .failure(.badData)
                }
                
                do {
                    let note = try decoder.decode(Note.self, from: data)
                    notes.append(note)
                } catch {
                    return result = .failure(.decode(error))
                }
            }
            result = .success(notes)
        } catch {
            return result = .failure(.readingDirectory(error))
        }

    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, NotesServiceError>) -> Void) {
        
        var noteToSave = note
        if noteToSave.dateModified == nil {
            noteToSave.dateModified = Date.init()
        }
        
        do {
            let noteData = try encoder.encode(noteToSave)
            guard let jsonString = String(data: noteData, encoding: .utf8) else { return }
            print(jsonString)
            
            if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first {
                let pathWithFilename = documentDirectory.appendingPathComponent("\(note.id).json")
                do {
                    try jsonString.write(to: pathWithFilename, atomically: true, encoding: .utf8)
                    self.responseQueue.async {
                        return completionHandler(.success(()))
                    }
                } catch {
                    self.responseQueue.async {
                        return completionHandler(.failure(.writing(error)))
                    }
                }
            }
        } catch {
            self.responseQueue.async {
                return completionHandler(.failure(.encode(error)))
            }
        }
    }

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("\(note.id).json")
            do {
                try fileManager.removeItem(at: pathWithFilename)
                return completionHandler(.success(()))
            } catch {
                return completionHandler(.failure(error))
            }
        }
    }
    
}
