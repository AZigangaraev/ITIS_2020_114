//
//  Note.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

struct Note: Codable {
    let id: Int?
    let title: String
    let text: String
    let dateModified: Date?
}
