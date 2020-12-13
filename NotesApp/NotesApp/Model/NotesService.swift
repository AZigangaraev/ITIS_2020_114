//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        do {
            var notes: [Note] = []
            let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            for file in files {
                let fileData = try Data(contentsOf: file)
                let decoder = JSONDecoder()
                let note = try decoder.decode(Note.self, from: fileData)
                notes.append(note)
            }
            completionHandler(.success(notes))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    /// Создаёт новую заметку, если {note.id}.json не существует; Перезаписывает заметку, если {note.id}.json существует.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let fileURL = documentsDirectory.appendingPathComponent("\(note.id).json")
            let encoder = JSONEncoder()
            let encodedNote = try encoder.encode(note)
            try encodedNote.write(to: fileURL)
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let fileURL = documentsDirectory.appendingPathComponent("\(note.id).json")
            try FileManager.default.removeItem(at: fileURL)
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(error))
        }
    }
}
