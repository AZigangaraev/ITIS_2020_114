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
    private let namePinnedArray = "pinnedNotesArray"
    private var array: [String] = []
    private var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
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
            if getCount() > indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            if getCount() > indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
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
        var accept = UIContextualAction()
        if (indexPath.row >= getCount()) {
            accept = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
                guard let pinNoteCheck = self?.pinNote(forIndex: indexPath.row) else { return completion(false) }
                if pinNoteCheck {
                    completion(true)
                    self?.loadNotes()
                } else {
                    completion(false)
                }
            }
            accept.image = UIImage(systemName: "pin")
        } else {
            accept = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
                self?.deleteNote(forIndex: indexPath.row)
                self?.loadNotes()
                completion(true)
            }
            accept.image = UIImage(systemName: "pin.slash")
        }
        accept.backgroundColor = .systemGreen
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
    
    // MARK: - IBAction
    
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
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
        if (getCount() <= index) {
            array.append(notes[index].id.uuidString)
            userDefaults.setValue(array, forKey: namePinnedArray)
            return true
        }
        return false
    }
    
    private func deleteNote(forIndex index: Int) {
        let arrayCount = getCount()
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
    
    private func getCount() -> Int {
        array = userDefaults.stringArray(forKey: namePinnedArray) ?? [String]()
        return array.count
    }
}
