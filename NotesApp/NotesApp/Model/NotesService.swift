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
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        fileManager = FileManager()
        path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    private func encode(note: Note) -> Data{
        guard let data = try? encoder.encode(note) else {
            fatalError()
        }
        return data
    }
    
    private func decode(data: Data) -> Note{
        if let note = try? decoder.decode(Note.self, from: data) {
            return note
        }else {
            fatalError()
        }
    }
    
    /// Получение списка всех заметок.
    func notes (completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        var notes = [Note]()
        var sortedNotes = [Note]()
        do {
            for folderPath in try fileManager.contentsOfDirectory(atPath: path.path) {
                let filePath = path.appendingPathComponent(folderPath)
                guard let data = fileManager.contents(atPath: filePath.path) else {
                    fatalError()
                }
                let note = decode(data: data)
                notes.append(note)
            }
            let sortNotes = notes.sorted { (firstNote, secondNote) -> Bool in
                return firstNote.dateModified ?? Date() > secondNote.dateModified ?? Date()
            }
            sortedNotes.append(contentsOf: sortNotes)
            
        }catch {
            completionHandler(.failure(error))
        }
        completionHandler(.success(sortedNotes))
    }
    
    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let filePath = path.appendingPathComponent("\(note.id).json")
        fileManager.createFile(atPath: filePath.path, contents: encode(note: note), attributes: nil)
    }
    
    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let filePath = path.appendingPathComponent("\(note.id).json")
        try? fileManager.removeItem(atPath: filePath.path)
    }
}
