//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    var note: Note?
    private let service = NotesService()
    
    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        
        loadNote()
    }

    private func loadNote() {
        guard let note = note else {
            return
        }
        guard let date = note.dateModified else {
            return
        }
        modifiedDateLabel.text = "\(date)"
        titleTextField.text = note.title
        textView.text = note.text
    }
    
    @objc private func saveTap(_ sender: Any) {
        guard var title = titleTextField.text else { fatalError() }
        guard var text = textView.text else { fatalError() }
        text = text.trimmingCharacters(in: [" "])
        title = title.trimmingCharacters(in: [" "])
        
        if var note = self.note {
            note.title = title
            note.text = text
            note.dateModified = Date()
            
            service.delete(note: note) { (result) in
                switch result {
                case .success():
                    print("Deleted")
                case .failure(let error):
                    print(error)
                }
            }
            if note.title != "" {
                service.save(note: note) { (result) in
                    switch result {
                    case .success():
                        print("Saved")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else if note.title == "" && note.text != ""{
                note.title = "No title"
                service.save(note: note) { (result) in
                    switch result {
                    case .success():
                        print("Saved")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } else {
            if title != ""{
                let note = Note(title: title, text: text, dateModified: Date())
                service.save(note: note) { (result) in
                    switch result {
                    case .success():
                        print("Saved")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else if title == "" && text != ""{
                title = "No title"
                let note = Note(title: title, text: text, dateModified: Date())
                service.save(note: note) { (result) in
                    switch result {
                    case .success():
                        print("Saved")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
