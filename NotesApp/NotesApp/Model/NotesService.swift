//
//  NotesService.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

class NotesService {
    
    enum NotesServiceError: Error {
        case notFound
    }
    
    /// Получение списка всех заметок.
    func notes(completionHandler: @escaping (Result<[Note], Error>) -> Void) {
        let documentsDirectoryUrl = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask).first!
        
        var fileListArray: [Note] = []
        do
          {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: documentsDirectoryUrl.path)
            print("fileList\(fileList)")
              for file in fileList {
                let DocumentUrl = documentsDirectoryUrl.appendingPathComponent("\(file)")
                print("url: \(DocumentUrl)")
                let text2 = try String(contentsOf: DocumentUrl, encoding: .utf8)
                print("text: \(text2)")
                let decoder = JSONDecoder()
                let object = try? decoder.decode(Note.self, from: text2.data(using: .utf8)!)
                fileListArray.append(object!)
              }
            
//            сортируем по дате изменения
            fileListArray.sort { (first, second) -> Bool in
                if first.dateModified! > second.dateModified! {
                    return true
                }
                return false
            }
            completionHandler(.success(fileListArray))
          }
          catch
          {
            completionHandler(.failure(NotesServiceError.notFound))
          }
    }

    /// Создаёт новую заметку, если note.id == nil; Редактирует существующую заметку, если note.id != nil.
    func save(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        print("1")

        let encoder = JSONEncoder()
        let encodedData = try! encoder.encode(note)

        guard
            let documentsDirectoryUrl = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask).first
        else {
            print("Could not create documents directory url")
            return
        }

        print("noteID: \(note.id)")
        let documentUrl = documentsDirectoryUrl.appendingPathComponent("\(note.id).json")
        
//    проверка есть ли еще
        let g  = try? documentUrl.checkResourceIsReachable()
           
        var pined = false;
        
        if(g != nil){
//            если изменяем, то сначала удаляем
            pined = NotesViewController().containsPined(x: note.id.uuidString)
            delete(note: note) { (_) in
            }
            print("изменил")
        }
        
//        создание
        guard FileManager.default.createFile(atPath: documentUrl.path, contents: encodedData) else {
            print("Could not create page at url: \(documentUrl)")
            return
        }
        
        if (pined){ NotesViewController().addPined(x: note.id.uuidString)}
        
        completionHandler(.success(()))

    }

    /// Удаление заметки.
    func delete(note: Note, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
        if (UserDefaults.standard.array(forKey: "pined") != nil) {
            if(NotesViewController().containsPined(x: note.id.uuidString)){
                NotesViewController().removePined(x: note.id.uuidString)
            }
        }
        
        guard
            let documentsDirectoryUrl = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask).first
        else {
            print("Could not create documents directory url")
            return
        }

        print("noteID: \(note.id)")
        let documentUrl = documentsDirectoryUrl.appendingPathComponent("\(note.id).json")
        

        try? FileManager.default.removeItem(at: documentUrl)
        
        completionHandler(.success(()))
        
    }
}
