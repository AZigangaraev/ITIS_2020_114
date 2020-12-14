//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

protocol NotesViewDelegate {
    func addNote(note: Note)
    func deleteNote(note: Note, indexPath: IndexPath?)
}

class NotesViewController: UIViewController, NotesViewDelegate, UITableViewDataSource, UITableViewDelegate {

    func addNote(note: Note) {
        self.notes.append(note)
        self.tableView.reloadData()
    }

    func deleteNote(note: Note, indexPath: IndexPath?) {
        noteService.delete(note: note) { result in
            switch result {
            case .success():
                if indexPath != nil {
                    self.notes.remove(at: indexPath!.item)
                    self.tableView.deleteRows(at: [indexPath!], with: .fade)
                } else {
                    for i in 0..<self.notes.count {
                        if self.notes[i].id == note.id {
                            self.notes.remove(at: i)
                            self.tableView.deleteRows(at: [IndexPath.init(index: i)], with: .fade)
                            break
                        }
                    }
                }
            case .failure(let error):
                print("Failed to delete \(error)")
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!

    private let noteService = NotesService()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self

        noteService.notes { result in
            switch result {
            case .success(let notes):
                self.notes = notes
                self.tableView.reloadData()
            case .failure(_):
                print("Failed To Fetch Notes")
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath:
            IndexPath, to destinationIndexPath: IndexPath
    ) {}

    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        controller.notesViewDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    private var notes: [Note] = []
    private var favourites: [Note] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
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
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let controller = editNoteController()
        controller.notesViewDelegate = self
        controller.note = notes[indexPath.item]
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteNote(note: notes[indexPath.item], indexPath: indexPath)
        }
    }

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
}

extension NotesViewController: UITableViewDropDelegate, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
}
