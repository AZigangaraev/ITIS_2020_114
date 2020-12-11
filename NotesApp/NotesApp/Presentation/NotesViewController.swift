//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private var tableView: UITableView!
    private let cellIdentifier = "Cell"
    private let notesService = NotesService()
    private let userDefaults = UserDefaults.standard
    private var notes: [Note] = [] 
    private let namePinnedArray = "pinnedNotesArray"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
    }
    
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            let int = userDefaults.array(forKey: namePinnedArray)?.count
            if (int ?? 0 > indexPath.row) {
                cell.accessoryType = .checkmark
            }
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notesService.delete(note: notes[indexPath.row]) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(()): break
                }
            }
            deleteNote(forIndex: indexPath.row)
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accept = UIContextualAction(style: .normal, title: nil) { (_, _, completion) in
            if self.pinNote(forIndex: indexPath.row) {
                completion(true)
                self.loadNotes()
            } else {
                completion(false)
            }
        }
        accept.backgroundColor = .systemGreen
        accept.image = UIImage(systemName: "pin")
        return UISwipeActionsConfiguration(actions: [accept])
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = editNoteController()
        controller.loadViewIfNeeded()
        controller.note = notes[indexPath.row]
        controller.setData()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: - Helpers
    
    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        guard let controller = storyboard.instantiateViewController(identifier: "EditNoteViewController") as? EditNoteViewController else { fatalError() }
        controller.notesService = notesService
        return controller
    }
    
    private func loadNotes() {
        notesService.notes() { [self] result in
            switch result {
            case .success(let arrayNote):
                self.notes = arrayNote
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func pinNote(forIndex index: Int) -> Bool {
        var array = userDefaults.array(forKey: namePinnedArray) as? [String] ?? [String]()
        array.append(notes[index].id.uuidString)
        userDefaults.setValue(array, forKey: namePinnedArray)
        return true
    }
    
    private func deleteNote(forIndex index: Int) {
        var array = userDefaults.array(forKey: namePinnedArray) as? [String] ?? [String]()
        let arrayCount = array.count
        if arrayCount > 0 && index < arrayCount {
            let idString = notes[index].id.uuidString
            for i in 0..<arrayCount {
                if array[i] == idString {
                    array.remove(at: i)
                    break
                }
            }
            userDefaults.setValue(array, forKey: namePinnedArray)
        }
    }
}
