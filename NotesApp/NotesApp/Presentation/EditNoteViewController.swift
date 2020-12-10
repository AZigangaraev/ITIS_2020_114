//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    weak var notesService: NotesService?
    var note: Note?

    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        modifiedDateLabel.text = "Modified date"
    }

    @objc private func saveTap(_ sender: Any) {
        guard let title = titleTextField.text else {
            fatalError("no title")
        }
        let saveNote: Note
        if var prevNote = note {
            prevNote.text = textView.text
            prevNote.title = title
            saveNote = prevNote
        } else {
            saveNote = Note(title: title, text: textView.text)
        }
        notesService?.save(note: saveNote) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(()) : break 
            }
        }
    }
    
    func setData() {
        guard let note = note else {
            return
        }
        if let date = note.dateModified {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let modDate = dateFormatter.string(from: date)
            modifiedDateLabel.text = "Last modified - \(modDate)"
        }
        titleTextField.text = note.title
        textView.text = note.text
    }
}
