//
//  TodoEditViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoEditViewController: UIViewController {
    
    private var todoItems: TodoItemModel?
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!
    func configure(todoItems: TodoItemModel) {
        self.todoItems = todoItems
    }
    override func viewDidLayoutSubviews() {
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        notesTextView.layer.cornerRadius = 5.0
        notesTextView.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = todoItems?.title
        notesTextView.text = todoItems?.notes
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tapedDoneButton(_:)))
        
    }
    
    
}
// MARK: - Actions
private extension TodoEditViewController {
    
    @objc func tapedDoneButton(_ sender: Any) {
        guard let title = titleTextField.text,
              let notes = notesTextView.text,
              let todoItems = todoItems else { return }
        let updatedTodoItem = TodoItemModel(id: todoItems.id, title: title, notes: notes, isDone: todoItems.isDone)
        FirebaseDBManager.updateTodoData(todoItem: updatedTodoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                self.showErrorAlert(error: error, vc: self)
            case.success():
                print("edit完了")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
