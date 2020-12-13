//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Teacher on 07.12.2020.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    var note: Note?
    var createPin = false
    var mainViewController: NotesViewController!
    @IBOutlet weak private  var pinButton: UIButton!
    
//    изменить пиновку через детальный обзор
    @IBAction private func editPin(_ sender: Any) {
        if(note != nil){
            if(createPin){
                createPin = false
                pinButton.setTitle("Pin", for: .normal)
            } else {
                createPin = true
                pinButton.setTitle("Unpin", for: .normal)
            }
        } else {
            if(createPin){
                createPin = false
                pinButton.setTitle("Pin", for: .normal)
            } else {
                createPin = true
                pinButton.setTitle("UnPin", for: .normal)
            }
            
        }
    }
    
    
    @IBOutlet private var modifiedDateLabel: UILabel!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if(note != nil){
        if(NotesViewController().containsPined(x: note!.id.uuidString)){
            pinButton.setTitle("Unpin", for: .normal)
        } else {
            pinButton.setTitle("Pin", for: .normal)
        }
        } else {
            pinButton.setTitle("Pin", for: .normal)
        }
        if(note != nil){
            titleTextField.text = note?.title
            textView.text = note?.text
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            modifiedDateLabel.text = formatter1.string(from: note!.dateModified!)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTap))
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
    }

//    создание и изменение
    @objc private func saveTap(_ sender: Any) {
        let title = titleTextField.text!.trimmingCharacters(in: .whitespaces)
        let text = textView.text!.trimmingCharacters(in: .whitespaces)
//        проверяем на пустотость
        if (title != "")&&(text != ""){
//            созданиие
        if(note == nil){
            self.note = Note(title: title, text: text, dateModified: Date())
            if(createPin){
                NotesViewController().addPined(x: note!.id.uuidString)
            }
        } else {
//            изменение
            note?.title = title
            note?.text = text
            note?.dateModified = Date()
            if(createPin){
                print("Нужно добавить пиновку: \(note!.id.uuidString)")
                print(UserDefaults.standard.array(forKey: "pined"))
                if(!NotesViewController().containsPined(x: note!.id.uuidString)){
                    print("Добавили пиновку")
                    print(UserDefaults.standard.array(forKey: "pined"))
                NotesViewController().addPined(x: note!.id.uuidString)
                }
            } else {
                print("Нужно удалить пиновку")
                print(UserDefaults.standard.array(forKey: "pined"))
                if(NotesViewController().containsPined(x: note!.id.uuidString)){
                print("Удалили пиновку")
                print(UserDefaults.standard.array(forKey: "pined"))
                NotesViewController().removePined(x: note!.id.uuidString)
                }
            }
        }
        NotesService().save(note: self.note! , completionHandler: { result in
            switch result {
            case .success( _):
                self.mainViewController.refresh()
                self.navigationController?.popViewController(animated: true)
            case .failure(_):
                fatalError()
            }
        })
        } else {
//            если пусто
            if(note == nil){
                self.mainViewController.refresh()
                self.navigationController?.popViewController(animated: true)
            } else {
                NotesService().delete(note: note! , completionHandler: { result in
                    switch result {
                    case .success( _):
                        print("удалилось")
                        self.mainViewController.refresh()
                        self.navigationController?.popViewController(animated: true)
                    case .failure(_):
                        fatalError()
                    }
                })
            }
        }

    }
}
