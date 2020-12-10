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
    private var notes: [Note] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        if editingStyle == .insert {
            print("insert")
        }
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
}
