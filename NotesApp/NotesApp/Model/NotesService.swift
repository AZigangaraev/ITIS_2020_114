//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
    }

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
    }
}
