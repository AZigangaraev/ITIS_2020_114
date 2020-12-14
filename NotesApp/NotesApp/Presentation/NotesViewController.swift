//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var pinnedNotes = UserDefaults.standard.object(forKey: "pinned") as? [String] ?? [String]()
    
    let notesService = NotesService(responseQueue: .main)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
                
        pinnedNotes.forEach { print($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
    }
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!

    // MARK: - Logic

    private var notes: [Note] = []
    private func loadNotes() {
        notesService.notes { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let notes):
                self.notes = notes
                self.rearrangeNotes()
                self.tableView.reloadData()
            }
        }
    }
    
    private func rearrangeNotes() {
        var index = 0
        notes.sort { $0.dateModified! > $1.dateModified! }
        notes.forEach {
            if pinnedNotes.contains($0.id.uuidString) {
                notes.insert($0, at: 0)
                notes.remove(at: index + 1)
            }
            index += 1
        }
        
        tableView.reloadData()
    }
    
    private func pin(noteId: UUID) {
        pinnedNotes.append(noteId.uuidString)
        UserDefaults.standard.set(pinnedNotes, forKey: "pinned")
        
        rearrangeNotes()
    }
    
    private func unpin(noteId: UUID) {
        pinnedNotes = pinnedNotes.filter { $0 != noteId.uuidString }
        UserDefaults.standard.set(pinnedNotes, forKey: "pinned")

        rearrangeNotes()
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    private let cellIdentifier = "cell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let note = notes[indexPath.row]
        
        if pinnedNotes.contains(note.id.uuidString) {
            cell.textLabel?.text = "Pinned: \(notes[indexPath.row].title)"
        } else {
            cell.textLabel?.text = notes[indexPath.row].title
        }
        cell.detailTextLabel?.text = notes[indexPath.row].text
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = editNoteController()
        controller.note = notes[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let note = self?.notes[indexPath.row] else { return }
            
            self?.unpin(noteId: note.id)
            self?.notesService.delete(note: note) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success():
                    print("succesfully deleted")
                    self?.loadNotes()
                    self?.tableView.reloadData()
                }
            }
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { [weak self] (action, sourceView, comletionHandler) in
            guard let id = self?.notes[indexPath.row].id else { return }
            self?.pin(noteId: id)
            
            comletionHandler(true)
        }
        
        let unpinAction = UIContextualAction(style: .normal, title: "Unpin") { [weak self] (action, sourceView, comletionHandler) in
            guard let id = self?.notes[indexPath.row].id else { return }
            self?.unpin(noteId: id)
            
            comletionHandler(true)
        }
        
        pinAction.backgroundColor = .green
        unpinAction.backgroundColor = .red
        
        let swipeConfiguration: UISwipeActionsConfiguration
        if pinnedNotes.contains(notes[indexPath.row].id.uuidString) {
            swipeConfiguration = UISwipeActionsConfiguration(actions: [unpinAction])
        } else {
            swipeConfiguration = UISwipeActionsConfiguration(actions: [pinAction])
        }
        return swipeConfiguration
    }

    // MARK: - Redirect to edit / create note
    
    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }

        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
    
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
