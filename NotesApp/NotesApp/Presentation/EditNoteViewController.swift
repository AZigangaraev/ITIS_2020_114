//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController, UITextViewDelegate {
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        return formatter
    }
    
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
            let date = note.dateModified
            titleTextField.text = note.title
            textView.text = note.text
            modifiedDateLabel.text = formatter.string(from: date)
            newNote = note
        } else {
            modifiedDateLabel.text = "New note"
            newNote = Note(title: "", text: "", dateModified: Date())
        }
    }
    @IBAction func deleteButton(_ sender: UIButton) {
        if let note = note {
            notesService.delete(note: note)
            self.navigationController?.popViewController(animated: true)
        }
    }
    	
    @objc private func saveTap(_ sender: Any) {
        
        newNote.title = titleTextField.text ?? ""
        newNote.text = textView.text
        notesService.save(note: newNote) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}



