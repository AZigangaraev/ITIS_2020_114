//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    let notesService = NotesService(responseQueue: DispatchQueue.main);
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        return formatter
    }
    
    var note: Note?

    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNote()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
    }

    @objc private func saveTap(_ sender: Any) {
        defer {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
        guard let title = titleTextField.text else { return }
        guard let text = textView.text else { return }
        
        guard title.trimmingCharacters(in: .whitespacesAndNewlines) != "" && text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            if note != nil {
                self.deleteCurrentNote()
            }
            return
        }
        
        if var note = note {
            note.modify(title: title, text: text, dateModified: Date.init())
            save(note: note)
        } else {
            let newNote = Note(title: title, text: text)
            save(note: newNote)
        }
    }
    
    private func save(note: Note) {
        notesService.save(note: note) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showAlert(error: error)
            case .success():
                print("success saving")
            }
        }
    }
    
    private func deleteCurrentNote() {
        guard let note = note else { return }
        
        notesService.delete(note: note) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showAlert(error: error)
            case .success():
                let defaults = UserDefaults.standard
                
                var pinned = defaults.object(forKey: "pinned") as? [String] ?? [String]()
                if pinned.contains(note.id.uuidString) {
                    pinned = pinned.filter { $0 != note.id.uuidString }
                    defaults.set(pinned, forKey: "pinned")
                }
            }
        }
    }
    
    private func loadNote() {
        if let note = note {
            guard let date = note.dateModified else { return }
            
            titleTextField.text = note.title
            textView.text = note.text
            modifiedDateLabel.text = formatter.string(from: date)
        } else {
            modifiedDateLabel.text = ""
        }
    }
    
    private func showAlert(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
