//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

 class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

     private let service = NotesService()

     override func viewDidLoad() {
         super.viewDidLoad()
         loadData()
     }


     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         loadData()
     }

     @IBAction func addTap(_ sender: Any) {
         let controller = editNoteController()
         navigationController?.pushViewController(controller, animated: true)
     }

     
     private var notes: [Note] = []

     @IBOutlet weak var tableView: UITableView!

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
             if self.service.checkPinedNote(note: note) {
                 cell.accessoryType = .checkmark
             }
             return cell
         } else {
             let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
             cell.textLabel?.text = note.title
             cell.detailTextLabel?.text = note.text
             if self.service.checkPinedNote(note: note) {
                 cell.accessoryType = .checkmark
             }
             return cell
         }
     }

     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         let controller = editNoteController()
         controller.note = notes[indexPath.row]
         navigationController?.pushViewController(controller, animated: true)
     }

     
     private func editNoteController() -> EditNoteViewController {
         guard let storyboard = storyboard else { fatalError() }

         
         return storyboard.instantiateViewController(identifier: "EditNoteViewController")
     }

     private func loadData(){
         service.notes { (result) in
             switch result {
             case .success(let newNotes):
                 self.notes = newNotes
             case.failure(let error):
                 print(error)
             }
         }
         tableView.reloadData()
     }

     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         true
     }

     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         if self.service.checkPinedNote(note: notes[indexPath.row]) {
             let action = UIContextualAction(style: .normal, title: "Unpin") { [weak self] (action, view, completionHandler) in
                 self?.service.unPin(id: indexPath.row) { (result) in
                     switch result {
                     case .success:
                         print("Unpined")
                     case .failure(let error):
                         print(error)
                     }
                 }
                 self?.loadData()
             }
             action.backgroundColor = .systemBlue
             return UISwipeActionsConfiguration(actions: [action])
         } else {
             let action = UIContextualAction(style: .normal, title: "Pin") { [weak self] (action, view, completionHandler) in
                 guard let note = self?.notes[indexPath.row] else {
                     return
                 }
                 self?.service.pin(note: note) { (result) in
                     switch result {
                     case .success:
                         print("Pined")
                     case .failure(let error):
                         print(error)
                     }
                 }
                 self?.loadData()
             }

             action.backgroundColor = .systemBlue
             loadData()
             return UISwipeActionsConfiguration(actions: [action])

         }
     }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, compleationHandler) in
             guard let note = self?.notes[indexPath.row], let service = self?.service else {
                 return
             }
             if service.checkPinedNote(note: note){
                 service.unPin(id: indexPath.row) { (result) in
                     switch result {
                     case .success:
                         print("Unpin")
                     case .failure(let error):
                         print(error)
                     }
                 };
             }
             service.delete(note: note, completionHandler: { (result) in
                 switch result {
                 case .success:
                     print("Deleted")
                 case .failure(let error):
                     print(error)
                 }
             });
             self?.loadData()
         }
         action.backgroundColor = .systemRed
         loadData()
         return UISwipeActionsConfiguration(actions: [action])
     }
 }
