//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    var note: Note?
    let notesService = NotesService()

    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        titleTextField.text = note?.title
        textView.text = note?.text
        if let date = note?.dateModified {
            let format = DateFormatter()
            format.dateFormat = "HH:mm E, d MMM y"
            modifiedDateLabel.text = format.string(from: date)
        }
    }

    @objc private func saveTap(_ sender: Any) {
        guard let title = titleTextField.text else { return }
        guard let text = textView.text else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if var note = note {
            if trimmedText == "" || trimmedTitle == "" {
                notesService.delete(note: note) { result in
                    switch result {
                    case .success(()):
                        print("Note was deleted 'cause it's empty")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
            note.text = text
            note.title = title
            notesService.save(note: note) { result in
                switch result {
                case .failure(let error) :
                    print(error)
                case .success(()): print("Successful")
                }
            }
            print(note)
            }
            
        } else {
            if trimmedText == "" || trimmedTitle == "" {
                print("empty note")
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
                return
            }
            let note = Note(title: title, text: text)
            notesService.save(note: note) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(()) : print("Successful")
                }
            }
            print(note)
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
