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
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        var notes = [Note]()
        var pinNotes = [Note]()
        var allNotes = [Note]()
        guard let list = UserDefaults.standard.stringArray(forKey: "array") ?? [String]() else { return }
        do {
            for string in try fileManager.contentsOfDirectory(atPath: path.path) {
                let filePath = path.appendingPathComponent(string)
                guard let data = fileManager.contents(atPath: filePath.path) else {
                    fatalError()
                }
                let note = decode(data: data)
                if list.contains(note.id.uuidString) {
                    pinNotes.append(note)
                }else {
                    notes.append(note)
                }
            }
//            let sortedPinNotes = pinNotes.sorted { (note1, note2) -> Bool in
//                return note1.dateModified ?? Date() > note2.dateModified ?? Date()
//            }
            let sortedNotes = notes.sorted { (note1, note2) -> Bool in
                return note1.dateModified ?? Date() > note2.dateModified ?? Date()
            }
            allNotes.append(contentsOf: pinNotes)
            allNotes.append(contentsOf: sortedNotes)
            
        }catch {
            completionHandler(.failure(error))
        }
        completionHandler(.success(allNotes))
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
    /// Закрепить заметку.
    func pin(note: Note, compleationHandler: @escaping (Result<Void, Error>) -> Void) {
        guard var list = UserDefaults.standard.stringArray(forKey: "array") ?? [String]() else {
            return
        }
        list.append(note.id.uuidString)
        UserDefaults.standard.setValue(list, forKey: "array")
    }
    
    /// Открепить заметку
    func unPin(id: Int, compleationHandler: @escaping (Result<Void, Error>) -> Void) {
        guard var list = UserDefaults.standard.stringArray(forKey: "array") ?? [String]() else {
            return
        }
        if id < list.count {
            list.remove(at: id)
            UserDefaults.standard.setValue(list, forKey: "array")
        }
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
    
    func checkPinedNote(note: Note) -> Bool {
        guard let list = UserDefaults.standard.stringArray(forKey: "array") else {
            return false
        }
        
        return list.contains(note.id.uuidString)
    }
}
