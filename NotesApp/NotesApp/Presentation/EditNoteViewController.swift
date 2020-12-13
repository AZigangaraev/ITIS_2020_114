//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    var note: Note?

    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    private let noteService = NotesService()
    var notesViewDelegate: NotesViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8

        if let note = note {
            self.textView.text = note.text
            self.titleTextField.text = note.title
        }
    }

    @objc private func saveTap(_ sender: Any) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && ((titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) != nil) {
            if note != nil {
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && ((titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) != nil) {

                    noteService.notes { result in
                        switch result {
                        case .success(_):
                            self.notesViewDelegate?.deleteNote(note: self.note!, indexPath: nil)
                        case .failure(_):
                            print("Failed To Fetch Notes")
                        }
                    }
                }
            }
        } else {
            if note == nil {
                let note = Note(title: titleTextField.text!, text: textView.text!)
                noteService.save(note: note, completionHandler: nil)
                self.notesViewDelegate?.addNote(note: note)
            }
        }

        self.navigationController?.popViewController(animated: true)
    }
}
