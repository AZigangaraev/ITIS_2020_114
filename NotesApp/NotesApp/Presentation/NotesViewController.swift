//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var notes: [Note] = []
    private let cellIdentifier = "Cell"
    @IBOutlet private var tableView: UITableView!
    
    let notesService = NotesService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
    }

    private func loadNotes() {
        notesService.notes() { [self] result in
            switch result {
            case .success(let arrayNote):
                self.notes = arrayNote
                tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = editNoteController()
        controller.loadViewIfNeeded()
        controller.note = notes[indexPath.row]
        controller.setData()
        navigationController?.pushViewController(controller, animated: true)
    }

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        guard let controller = storyboard.instantiateViewController(identifier: "EditNoteViewController") as? EditNoteViewController else { fatalError() }
        controller.notesService = notesService
        return controller
    }
}
