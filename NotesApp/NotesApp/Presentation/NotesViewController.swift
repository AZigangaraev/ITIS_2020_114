//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
      private let notesService = NotesService()
      private var notes: [Note] = []
      private var pinNotes: [Note] = []
      private var pinNotesIDs = UserDefaults.standard.object(forKey: "pin") as? [String] ?? [String]()
      
    private func loadData() {
        notes = []
        pinNotes = []

        notesService.notes { result in
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                print(error)
            }
        }
        
        for myId in pinNotesIDs {
            let id = UUID(uuidString: myId)
            if let index = notes.firstIndex(where: { $0.id == id }) {
                let pinNote = notes.remove(at: index)
                pinNotes.append(pinNote)
            }
        }
        
        
        tableView.reloadData()
    }
    
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? pinNotes.count : notes.count
    }
    
    private let pinNoteCellIdentifier = "pinNoteCell"
    private let noteCellIdentifier = "noteCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let note = pinNotes[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: pinNoteCellIdentifier) {
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
        let editVC = editNoteController()
        editVC.note = indexPath.section == 0 ? pinNotes[indexPath.row] : notes[indexPath.row]
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var action: [UIContextualAction] = []
    
        let pinRow = UIContextualAction(style: .normal, title: nil) { _,_,_ in
            self.pinNote(at: indexPath)
        }
        
        let unpinRow = UIContextualAction(style: .normal, title: nil) { _,_,_ in
            self.unpinNote(at: indexPath)
        }
        
        action.append(indexPath.section == 0 ? unpinRow : pinRow)
        let swipeAction = UISwipeActionsConfiguration(actions: action)
        return swipeAction
    }
    
    private func pinNote(at indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let index = pinNotes.firstIndex { $0.dateModified < note.dateModified } ?? pinNotes.count
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        pinNotes.insert(note, at: index)
        let newIndexPath = IndexPath(row: index, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .fade)
        pinNotesIDs.append(note.id.uuidString)
        UserDefaults.standard.set(pinNotesIDs, forKey: "pin")
    }
    
    private func unpinNote(at indexPath: IndexPath) {
        let note = pinNotes[indexPath.row]
        let index = notes.firstIndex { $0.dateModified < note.dateModified } ?? notes.count
        pinNotes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        notes.insert(note, at: index)
        let newIndexPath = IndexPath(row: index, section: 1)
        tableView.insertRows(at: [newIndexPath], with: .fade)
        if let pinIndex = pinNotesIDs.firstIndex(of: note.id.uuidString) {
            pinNotesIDs.remove(at: pinIndex)
            UserDefaults.standard.set(pinNotesIDs, forKey: "pin")
        }
    }
    
    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        return storyboard.instantiateViewController(identifier: "EditNoteViewController")
    }
}
