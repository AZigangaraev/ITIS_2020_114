//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }

    private var notes: [Note] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    private let cellIdentifier = "Cell"

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
    }

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }

        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
}
