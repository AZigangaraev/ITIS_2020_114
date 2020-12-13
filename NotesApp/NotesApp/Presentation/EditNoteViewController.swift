//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController, UITextViewDelegate {
    var note: Note?
    private let notesService = NotesService()
    private var newNote: Note!
    
    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.delegate = self
        
        if let note = note {
            titleTextField.text = note.title
            textView.text = note.text
            modifiedDateLabel.text = note.dateModified.toString()
            newNote = note
        } else {
            modifiedDateLabel.text = "New Note"
            newNote = Note(title: "", text: "", dateModified: Date())
        }
    }
    
    @objc private func saveTap(_ sender: Any) {
        guard !isNoteEmpty() else {
            if let note = note {
                notesService.delete(note: note) { result in
                    switch result {
                    case .success(()):
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } else {
                navigationController?.popViewController(animated: true)
            }
            return
        }
        
        newNote.title = titleTextField.text ?? ""
        newNote.text = textView.text
        notesService.save(note: newNote) { result in
            switch result {
            case .success(()):
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction private func titleEditingChanged(_ sender: UITextField) {
        updateModifiedDate()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateModifiedDate()
    }
    
    private func updateModifiedDate() {
        newNote.dateModified = Date()
    }
    
    private func isNoteEmpty() -> Bool {
        guard let title = titleTextField.text else { return true }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty && trimmedText.isEmpty
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy 'at' HH:mm:ss"
        return formatter.string(from: self)
    }
}
