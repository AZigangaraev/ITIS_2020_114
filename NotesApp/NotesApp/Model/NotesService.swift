//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    
    static let shared = NotesService()
    
    private init() {}
    
    private let pathName: String = "data"
    private let fileName: String = "notes.json"
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        do {
            if DataManager.fileExists(pathName: pathName, fileName: fileName) == false {
                try DataManager.saveDataToCash(pathName: pathName, fileName: fileName, data: "[]".data(using: .utf8) ?? Data())
            }
            let data = try DataManager.getDataFromCash(pathName: pathName, fileName: fileName)
            let result = try JSONDecoder().decode([Note].self, from: data)
            completionHandler(.success(result.sorted(by: { l, r in
                l.dateModified > r.dateModified
            })))
        } catch {
            completionHandler(.failure(error))
            print(error.localizedDescription)
        }
    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            var notes = try JSONDecoder().decode(
                [Note].self,
                from: try DataManager.getDataFromCash(pathName: pathName, fileName: fileName)
            )
            if let id = note.id, let index = notes.firstIndex(where: { item in
                item.id == id
            }) {
                notes[index] = note
            } else {
                notes.append(note)
            }
            try DataManager.saveDataToCash(
                pathName: pathName,
                fileName: fileName,
                data: try JSONEncoder().encode(notes)
            )
            completionHandler(.success(Void()))
        } catch {
            completionHandler(.failure(error))
            print(error.localizedDescription)
        }
    }

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard let id = note.id else {
            completionHandler(.failure(CustomError(errorDescription: "Id required")))
            return
        }
        do {
            var notes = try JSONDecoder().decode(
                [Note].self,
                from: try DataManager.getDataFromCash(pathName: pathName, fileName: fileName)
            )
            notes = notes.filter { note in
                note.id != id
            }
            try DataManager.saveDataToCash(
                pathName: pathName,
                fileName: fileName,
                data: try JSONEncoder().encode(notes)
            )
            completionHandler(.success(Void()))
        } catch {
            completionHandler(.failure(error))
            print(error.localizedDescription)
        }
    }
}
