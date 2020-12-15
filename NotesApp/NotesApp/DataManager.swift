//
//  DataManager.swift
//  NotesApp
//
//  Created by Олег Романов on 12/14/20.
//

import Foundation
import UIKit

class DataManager {
    static func getDataFromCash(pathName: String, fileName: String) throws -> Data {
        guard let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CustomError(errorDescription: "Fuck")
        }
        let directory = dir.appendingPathComponent(pathName)
        let filePath = directory.appendingPathComponent(fileName)
        return try Data(contentsOf: filePath)
    }

    static func saveDataToCash(pathName: String, fileName: String, data: Data) throws {
        guard let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CustomError(errorDescription: "Fuck")
        }
        let directory = dir.appendingPathComponent(pathName)
        let filePath = directory.appendingPathComponent(fileName)
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDir) == false {
            print("creating directory " + directory.path)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        print("write to " + filePath.path)
        try data.write(to: filePath, options: .atomic)
    }

    static func deleteCashAtPath(pathName: String) throws {
        if let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first {
            let directory = dir.appendingPathComponent(pathName)
            if FileManager.default.fileExists(atPath: directory.path) {
                print("deleting " + directory.path)
                try FileManager.default.removeItem(at: directory)
            }
        }
    }
    
    static func fileExists(pathName: String, fileName: String) -> Bool {
        if let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first {
            let directory = dir.appendingPathComponent(pathName)
            let filePath = directory.appendingPathComponent(fileName)

            return FileManager.default.fileExists(atPath: filePath.path)
        }
        return false
    }
}
