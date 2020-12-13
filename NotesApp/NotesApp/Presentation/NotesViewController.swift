//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var notesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    private func loadData() {
        notesService.notes { result in
            switch result {
                case .success(let notesFiller):
                    self.notes = notesFiller
                case .failure(let error):
                    print(error)
            }
        }
        countOfPinnedNotes = getCountOfPinnedNotes()
        notesTableView.reloadData()
    }

    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }

    private var notes: [Note] = []
    private var notesService = NotesService()
    var countOfPinnedNotes = 0
    var userDefault = UserDefaults.standard
    private var pinnedNotesKey = "pinnedNotesKey"

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    private let cellIdentifier = "Cell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            cell.accessoryType = .none
            if (indexPath.row < countOfPinnedNotes) {
                cell.accessoryType = .checkmark
            }
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            cell.accessoryType = .none
            if (indexPath.row < countOfPinnedNotes) {
                cell.accessoryType = .checkmark
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (indexPath.row < countOfPinnedNotes) {
            let action = UIContextualAction(style: .normal, title: "Unpin")
            { [weak self] (action, view, completionHandler) in
                self?.unpinNoteTapped(rowAt: indexPath.row)
                completionHandler(true)
            }
            
            action.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            let action = UIContextualAction(style: .normal, title: "Pin")
            { [weak self] (action, view, completionHandler) in
                self?.pinNoteTapped(rowAt: indexPath.row)
                completionHandler(true)
            }
            
            action.backgroundColor = .systemOrange
            return UISwipeActionsConfiguration(actions: [action])
        }
    }
    
    private func pinNoteTapped(rowAt row: Int) {
        notesService.pinNote(note: notes[row])
        loadData()
    }
    
    private func unpinNoteTapped(rowAt row: Int) {
        notesService.unpinNote(note: notes[row])
        loadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notesService.delete(note: notes[indexPath.row]) { result in
                switch result {
                case .success():
                    print("Succes")
                case .failure(let error):
                    print(error)
                }
            }
        }
        loadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let editNoteViewController = editNoteController()
        
        editNoteViewController.note = notes[indexPath.row]
        show(editNoteViewController, sender: nil)
    }

    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }

        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
    
    private func getCountOfPinnedNotes() -> Int {
        let pinnedNotesId = userDefault.stringArray(forKey: pinnedNotesKey) ?? [String]()
        return pinnedNotesId.count
    }
}
