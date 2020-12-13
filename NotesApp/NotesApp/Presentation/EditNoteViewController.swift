//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    var note: Note?
    private var notesService = NotesService()

    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        
        guard let note = note else { return }
        titleTextField.text = note.title
        textView.text = note.text
        guard let date = note.dateModified else { return }
        modifiedDateLabel.text = "\(String(describing: date))"
        
    }

    @objc private func saveTap(_ sender: Any) {
        guard var title = titleTextField.text else { return }
        guard var text = textView.text else { return }
        title = title.trimmingCharacters(in: [" "])
        text = text.trimmingCharacters(in: [" "])
        
        if var note = note {
            if edited() {
                note.title = title
                note.text = text
                if (text == "" && title == "") {
                    notesService.delete(note: note) { result in
                        switch result {
                        case .success():
                            print("Succes")
                        case .failure(let error):
                            print(error)
                        }
                    }
                } else {
                    notesService.save(note: note) { result in
                        switch result {
                        case .success():
                            print("Succes")
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        } else {
            if (title != "" || text != "") {
                let note = Note(title: title, text: text)
                notesService.save(note: note) { result in
                    switch result {
                    case .success():
                        print("Succes")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func edited() -> Bool {
        guard let note = note else { return false }
        let title = note.title
        let text = note.text
        
        if (title == titleTextField.text && text == textView.text) {
            return false
        }
        
        return true
    }
}
