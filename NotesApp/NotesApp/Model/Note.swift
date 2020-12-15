//
//  Note.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import Foundation

struct Note: Codable {
    var id: UUID
    var title: String
    var text: String
    var dateModified: Date

    init(title: String, text: String, dateModified: Date) {
        id = UUID()
        self.title = title
        self.text = text
        self.dateModified = dateModified
    }
}
