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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.text = note?.text
        titleTextField.text = note?.title
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
    }

    @objc private func saveTap(_ sender: Any) {
        guard var note = note else {
            return
        }
        note.dateModified = Date()
        note.text = textView.text
        note.title = titleTextField.text ?? ""
        NotesService.shared.save(note: note) { [weak self] result in
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
