//
//  NotesViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let keyUserDefauls = "pined"
    @IBOutlet weak var tableView: UITableView!
    var userDefaults = UserDefaults.standard
    private var notes: [Note] = []
    private let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        если нет, то создаем пустой массив для пиновки, чтобы в дальнейшем не выходили ошибки
        if (self.userDefaults.array(forKey: keyUserDefauls) == nil) {
            print("news")
            let g:[String] = []
            self.userDefaults.set(g, forKey: keyUserDefauls)
        }
        refresh()
    }
    

//    добавление
    @IBAction func addTap(_ sender: Any) {
        let controller = editNoteController()
        navigationController?.pushViewController(controller, animated: true)
    }


// сколько всего ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    
//    как выглядит ячейка
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            print("new")
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.text
            return cell
        }
    }

//    переход на детальный обзор
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = editNoteController()
        controller.note = notes[indexPath.row]
        controller.mainViewController = self
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    обновление всех данных на главной странице
    func refresh(){
        NotesService().notes() { result in
            switch result {
            case .success(let notes):
                self.notes = notes
                print("notes: \(self.notes)")
            case .failure(_):
                fatalError()
            }
        }
//        это сделано, чтобы вывести запиненные наверх
        var g:[Note] = []
        var g1:[Note] = []
        var j = 0
        print("notes: \(notes)")
        print("notesC: \(notes.count)")
        var forDeleteItems:[Int] = []
        for i in notes{
            print("j: \(j)")
            let id = i.id.uuidString
            if(containsPined(x: id)){
                forDeleteItems.append(j)
                g.append(i)
            } else {
                g1.append(i)
            }
            j = j + 1
        }

        notes = g + g1
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    свайп для пина
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = notes[indexPath.row]
        let id = note.id.uuidString
        if containsPined(x: id){
//            если уже запинен, и нужно распинить
            let filterAction = UIContextualAction(style: .normal, title: "Unpin") { (action, view, bool) in
                self.removePined(x: id)
                self.refresh()
               }
            filterAction.backgroundColor = UIColor.gray
            let configuration = UISwipeActionsConfiguration(actions: [filterAction])
            configuration.performsFirstActionWithFullSwipe = false
                return configuration
        } else {
//            запинивание
            let filterAction = UIContextualAction(style: .normal, title: "Pin") { (action, view, bool) in
                self.addPined(x: id)
                self.refresh()
               }
            filterAction.backgroundColor = UIColor.blue
            let configuration = UISwipeActionsConfiguration(actions: [filterAction])
            configuration.performsFirstActionWithFullSwipe = false
                return configuration
        }
       
    }
    
//    функция для проверки запиненности
    func containsPined(x: String) -> Bool{
        let array = self.userDefaults.array(forKey: keyUserDefauls) as! [String]
        for i in array{
            if(i == x) {
                return true
            }
        }
        return false
    }
    
//    функция удаления запиненности
    func removePined(x: String){
        print("remmove pin")
        var array = self.userDefaults.array(forKey: keyUserDefauls) as! [String]
        var j = 0
        for i in array{
            if(i == x) {
                array.remove(at: j)
            }
            j = j + 1
        }
        self.userDefaults.set(array, forKey: keyUserDefauls)
    }
    
//    добавление запиненности
    func addPined(x: String){
        print("add pin: \(x)")
        var array = UserDefaults.standard.array(forKey: self.keyUserDefauls) as! [String]
        array.append(x)
        UserDefaults.standard.setValue(array, forKey: self.keyUserDefauls)
    }
    

//    удаление ячеек свайпом
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let note = notes[indexPath.row]
            NotesService().delete(note: note , completionHandler: { result in
                switch result {
                case .success( _):
                    print("удалилось")
                    self.refresh()
                case .failure(_):
                    fatalError()
                }
            })
        }
    }
    
    
//    достать детальный контроллер
    private func editNoteController() -> EditNoteViewController {
        guard let storyboard = storyboard else { fatalError() }
        let editViewController = storyboard.instantiateViewController(identifier: "EditNoteViewController") as! EditNoteViewController
        editViewController.mainViewController = self
        return  editViewController
    }
}
