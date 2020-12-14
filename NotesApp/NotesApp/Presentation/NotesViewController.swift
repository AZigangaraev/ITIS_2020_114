//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private var tableView : UITableView!
    var notesServices = NotesService()
    var newNotes: [Note] = []
    var pinnedNotes = UserDefaults.standard.object(forKey: "pin") as? [String] ?? [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNotes()
        sort()
        tableView.reloadData()
    }
    
    func pinNote(noteId: String) {
        pinnedNotes.append(noteId)
        UserDefaults.standard.setValue(pinnedNotes, forKey: "pin")
        sort()
        tableView.reloadData()
    }
    
    func sort() {
        notes.sort{ $0.dateModified! > $1.dateModified! }
        var index = 0
        for note in notes {
            if pinnedNotes.contains(note.id.uuidString)
            {
                notes.insert(note, at: 0)
                notes.remove(at: index + 1)
            }
            index += 1
        }
    }
    
    func unpinNote(noteId: String) {
        var index = 0
        for note in pinnedNotes {
            if note == noteId {
                pinnedNotes.remove(at: index)
                UserDefaults.standard.setValue(pinnedNotes, forKey: "pin")
                sort()
                tableView.reloadData()
                break
            }
            index += 1
        }
    }

    func getNotes() {
        notesServices.notes() { [self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let getNotes):
                self.newNotes = getNotes
                notes = getNotes
                print(notes)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.text
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = editNoteController()
        controller.note = notes[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            self.notesServices.delete(note: self.notes[indexPath.row]) { result in
                switch result {
                case .success(()):
                    print("Deleted")
                case .failure(let error):
                    print(error)
                }
            }
            self.notes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        let pinAction = UIContextualAction(style: .normal, title: "Pin") {
            (action, sourceView, completionHandler) in
            self.pinNote(noteId: self.notes[indexPath.row].id.uuidString)
        }
        pinAction.backgroundColor = .purple
        
        let unpinAction = UIContextualAction(style: .normal, title: "Unpin"){
            (action, sourceView, completionHandler) in
            self.unpinNote(noteId: self.notes[indexPath.row].id.uuidString)
        }
        unpinAction.backgroundColor = .darkGray
        
        let swipeConfig: UISwipeActionsConfiguration
        if pinnedNotes.contains(notes[indexPath.row].id.uuidString) {
            swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, unpinAction])
            return swipeConfig
        } else {
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
            return swipeConfig
        }
        
    }
    

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }

        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
}
