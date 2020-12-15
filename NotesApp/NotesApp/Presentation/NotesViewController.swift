//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
    }
    
    private func loadNotes() {
        NotesService.shared.notes { [weak self] result in
            switch result {
            case let .success(data):
                self?.notes = data
                self?.tableView.reloadData()
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }

    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        controller.note = Note(title: "", text: "")
        navigationController?.pushViewController(controller, animated: true)
    }

    private var notes: [Note] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    private let cellIdentifier = "Cell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.text
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = editNoteController()
        controller.note = notes[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        NotesService.shared.delete(note: note) { [weak self] result in
            switch result {
            case .success:
                self?.notes.remove(at: indexPath.row)
                tableView.reloadData()
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
