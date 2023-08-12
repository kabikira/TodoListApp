//
//  TodoEditViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoEditViewController: UIViewController {
    // 編集するためのTodoアイテムの具体的なデータを保持するため
    private var todoItems: TodoItemModel?
    // 編集されるTodoアイテムがどのTodoリストカテゴリに属しているかを示す
    private var selectedTodos: String?
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!
    // Routre から呼び出されどのTodoリストカテゴリに属しているかを知る
    // 編集するTodoアイテムを渡してもらう
    // TODO: func configure はどこからでも呼べるので修正したほうがいいかもしれない
    func configure(todoItems: TodoItemModel, todos: String) {
        self.todoItems = todoItems
        self.selectedTodos = todos
    }
    override func viewDidLayoutSubviews() {
        styleTextField(titleTextField)
        styleTextView(notesTextView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        titleTextField.delegate = self
        titleTextField.text = todoItems?.title
        notesTextView.text = todoItems?.notes
        observeNotifications()
        // Doneボタンでtodo編集してセルを更新させてとじる
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.done(), style: .done, target: self, action: #selector(tapedDoneButton(_:)))
        // 閉じるボタン
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localizable.cancel(), style: .plain, target: self, action: #selector(tapedCancelBotton(_:)))
    }
    
}
// MARK: - ButtonActions
private extension TodoEditViewController {
    // 入力されたデータの編集を行う
    @objc func tapedDoneButton(_ sender: Any) {
        guard let title = titleTextField.text,
              let notes = notesTextView.text,
              let todoItems = todoItems,
              let selectedTodos = selectedTodos else { return }
        let updatedTodoItem = TodoItemModel(id: todoItems.id, title: title, notes: notes, isDone: todoItems.isDone)
        FirebaseDBManager.updateTodoData(todos: selectedTodos,todoItem: updatedTodoItem) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case.failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                case.success():
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    @objc func tapedCancelBotton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Design
    func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 12
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowRadius = 10.0
    }

    func styleTextView(_ textView: UITextView) {
        textView.layer.cornerRadius = 12
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView.layer.shadowOpacity = 0.1
        textView.layer.shadowRadius = 10.0
    }
    // MARK: - Notification Handling
    func observeNotifications() {
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NetworkMonitor.connectionLost, object: nil)
    }
    @objc func connectionLost() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Alert.okAlert(vc: self, title: R.string.localizable.networkErrors(), message: NetworkMonitor.connectionLost.rawValue)
        }
    }

}
// MARK: - UITextViewDelegate
extension TodoEditViewController: UITextViewDelegate {
    // 入力されたときの文字制限をチェック
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return notesTextView.text.count + (text.count - range.length) <= MaxNumCharacters.maxNotes.rawValue
    }
}
// MARK: - UITextFieldDelegate
extension TodoEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 入力されたときの文字制限をチェック
        let titleText = titleTextField.text ?? ""
        return titleText.count + (string.count - range.length) <= MaxNumCharacters.maxTitle.rawValue
    }
    // testFieldに入力するとき
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 少し大きくなるアニメーション
        UIView.animate(withDuration: 0.2) {
            textField.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    // 入力が終わったとき
    func textFieldDidEndEditing(_ textField: UITextField) {
        // もとに戻るアニメーション
        UIView.animate(withDuration: 0.2) {
            textField.transform = CGAffineTransform.identity
        }
    }
}
