//
//  TodoEditViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoEditViewController: UIViewController {
    
    private var todoItems: TodoItemModel?
    private var selectedTodos: String?
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!
    func configure(todoItems: TodoItemModel, todos: String) {
        self.todoItems = todoItems
        self.selectedTodos = todos
    }
    override func viewDidLayoutSubviews() {
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        notesTextView.layer.cornerRadius = 5.0
        notesTextView.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        titleTextField.delegate = self
        titleTextField.text = todoItems?.title
        notesTextView.text = todoItems?.notes
        observeNotifications()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tapedDoneButton(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tapedCancelBotton(_:)))
    }
    
    
}
// MARK: - Actions
private extension TodoEditViewController {
    
    @objc func tapedDoneButton(_ sender: Any) {
        guard let title = titleTextField.text,
              let notes = notesTextView.text,
              let todoItems = todoItems,
              let selectedTodos = selectedTodos else { return }
        print(selectedTodos)
        let updatedTodoItem = TodoItemModel(id: todoItems.id, title: title, notes: notes, isDone: todoItems.isDone)
        FirebaseDBManager.updateTodoData(todos: selectedTodos,todoItem: updatedTodoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            case.success():
                print("edit完了")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @objc func tapedCancelBotton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Notification Handling
    func observeNotifications() {
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NetworkMonitor.connectionLost, object: nil)
    }
    @objc func connectionLost() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Alert.okAlert(vc: self, title: "Network Errors", message: NetworkMonitor.connectionLost.rawValue)
        }
    }

}
// MARK: - UITextViewDelegate
extension TodoEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return notesTextView.text.count + (text.count - range.length) <= MaxNumCharacters.maxNotes.rawValue
    }
}
// MARK: - UITextFieldDelegate
extension TodoEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let titleText = titleTextField.text ?? ""
        return titleText.count + (string.count - range.length) <= MaxNumCharacters.maxTitle.rawValue
    }
}
