//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let notesService = NotesService()
    private var notes: [Note] = []
    private var pinnedNotes: [Note] = []
    private var pinnedNotesIDs = UserDefaults.standard.object(forKey: "pinned") as? [String] ?? [String]()
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    private func loadData() {
        notes = []
        pinnedNotes = []

        notesService.notes { result in
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        
        for strId in pinnedNotesIDs {
            let id = UUID(uuidString: strId)
            if let index = notes.firstIndex(where: { $0.id == id }) {
                let pinnedNote = notes.remove(at: index)
                pinnedNotes.append(pinnedNote)
            }
        }
        
        let sortPredicate: (Note, Note) -> Bool = { $0.dateModified > $1.dateModified }
        pinnedNotes.sort(by: sortPredicate)
        notes.sort(by: sortPredicate)
        
        tableView.reloadData()
    }
    
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? pinnedNotes.count : notes.count
    }
    
    private let pinnedNoteCellIdentifier = "PinnedNoteCell"
    private let noteCellIdentifier = "NoteCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let note = pinnedNotes[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: pinnedNoteCellIdentifier) {
                cell.textLabel?.text = note.title
                cell.detailTextLabel?.text = note.text
                cell.accessoryView = UIImageView(image: UIImage(systemName: "pin"))
                return cell
            }
        case 1:
            let note = notes[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: noteCellIdentifier) {
                cell.textLabel?.text = note.title
                cell.detailTextLabel?.text = note.text
                return cell
            }
        default:
            break
        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let editNoteVC = editNoteController()
        editNoteVC.note = indexPath.section == 0 ? pinnedNotes[indexPath.row] : notes[indexPath.row]
        navigationController?.pushViewController(editNoteVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
    
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] _,_,_ in
            deleteNote(at: indexPath)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        actions.append(deleteAction)
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { _,_,_ in
            self.pinNote(at: indexPath)
        }
        pinAction.image = UIImage(systemName: "pin.fill")
        pinAction.backgroundColor = .systemOrange
        
        let unpinAction = UIContextualAction(style: .normal, title: nil) { _,_,_ in
            self.unpinNote(at: indexPath)
        }
        unpinAction.image = UIImage(systemName: "pin.slash.fill")
        unpinAction.backgroundColor = .systemOrange
        
        actions.append(indexPath.section == 0 ? unpinAction : pinAction)
        let swipeActions = UISwipeActionsConfiguration(actions: actions)
        return swipeActions
    }
    
    private func deleteNote(at indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        notesService.delete(note: section == 0 ? pinnedNotes[row] : notes[row]) { [self] result in
            switch result {
            case .success(()):
                _ = section == 0 ? pinnedNotes.remove(at: row) : notes.remove(at: row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func pinNote(at indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let index = pinnedNotes.firstIndex { $0.dateModified < note.dateModified } ?? pinnedNotes.count
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        pinnedNotes.insert(note, at: index)
        let newIndexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .fade)
        pinnedNotesIDs.append(note.id.uuidString)
        UserDefaults.standard.set(pinnedNotesIDs, forKey: "pinned")
    }
    
    private func unpinNote(at indexPath: IndexPath) {
        let note = pinnedNotes[indexPath.row]
        let index = notes.firstIndex { $0.dateModified < note.dateModified } ?? notes.count
        pinnedNotes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        notes.insert(note, at: index)
        let newIndexPath = IndexPath(row: index, section: 1)
        tableView.insertRows(at: [newIndexPath], with: .fade)
        if let pinIndex = pinnedNotesIDs.firstIndex(of: note.id.uuidString) {
            pinnedNotesIDs.remove(at: pinIndex)
            UserDefaults.standard.set(pinnedNotesIDs, forKey: "pinned")
        }
    }
    
    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
}
