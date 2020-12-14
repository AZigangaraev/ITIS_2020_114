//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    //: -Public Methdos

    private final let folderName = "Notes"
    private final let fm = FileManager.default

    required init() {
        do {
            let docsurl = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let notesFolder = docsurl.appendingPathComponent(folderName)

            if (try? notesFolder.checkResourceIsReachable()) ?? false {
            } else {
                try fm.createDirectory(at: notesFolder, withIntermediateDirectories: false, attributes: nil)
            }
        } catch {
            print(error)
        }
    }

    /// Получение списка всех заметок.
    public func notes(completionHandler: ((Result<[Note], Error>) -> Void)?) {
        var notes = [Note]()
        do {
            let notesFolder = try getNotesFolder()
            let fileList = try fm.contentsOfDirectory(at: notesFolder, includingPropertiesForKeys: nil)

            let decoder = JSONDecoder.init()

            try fileList.forEach { (fileUrl) in
                notes.append(try decoder.decode(Note.self, from: Data(contentsOf: fileUrl)))
            }

            if let completition = completionHandler {
                completition(.success(notes))
            }
        } catch {
            if let completition = completionHandler {
                completition(.failure(error))
            }
        }
    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    public func save(note: Note, completionHandler: ((Result<Void, Error>) -> Void)?) {
        print("Saving new Note id: \(note)")
        do {
            let notesFolder = try getNotesFolder()

            let encode = JSONEncoder.init()
            let fileUrl = notesFolder.appendingPathComponent("\(note.id).json")
            fm.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)

            try encode.encode(note).write(to: fileUrl)

            if let completition = completionHandler {
                completition(.success(()))
            }
        } catch {
            if let completition = completionHandler {
                completition(.failure(error))
            }
        }
    }

    /// Удаление заметки.
    public func delete(note: Note, completionHandler: ((Result<Void, Error>) -> Void)?) {
        print("Deleting Note")
        do {
            let notesFolder = try getNotesFolder()
            let fileUrl = notesFolder.appendingPathComponent("\(note.id).json")

            if fm.fileExists(atPath: fileUrl.path) {
                try fm.removeItem(atPath: fileUrl.path)
            } else {
                print("File does not exist")
            }

            if let completition = completionHandler {
                completition(.success(()))
            }

        } catch {
            if let completition = completionHandler {
                completition(.failure(error))
            }
        }
    }

    //: -Private Helpers

    private func getNotesFolder() throws -> URL {
        do {
            let docsurl = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let notesFolder = docsurl.appendingPathComponent(folderName)

            return notesFolder
        } catch {
            throw error
        }
    }
}
