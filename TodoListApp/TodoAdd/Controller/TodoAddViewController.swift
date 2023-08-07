//
//  TodoAddViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoAddViewController: UIViewController {

    private var selectedTodos: String?

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!

    func configure(todos: String) {
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
        observeNotifications()
        navigationItem.title = "AddTodo"
        // TODO: Doneでtodo編集してセルを更新させてとじる
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.done(), style: .done, target: self, action: #selector(tapedDoneBotton(_:)))
        // TODO: 閉じる
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localizable.cancel(), style: .plain, target: self, action: #selector(tapedCancelBotton(_:)))

    }
}
// MARK: - Actions
private extension TodoAddViewController {
    @objc func tapedDoneBotton(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let notes = notesTextView.text ?? ""
        guard let selectedTodos = selectedTodos else { return }
        // ログイン済みか確認 // FirestoreにTodoデータを作成する
        FirebaseDBManager.createTodo(title: title, notes: notes, todos: selectedTodos) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.success():
                    print("データベース作成")
                    //                NotificationCenter.default.post(name: .updateTodoListView, object: nil)

                case .failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
        // Todo一覧画面に戻る処理
        self.navigationController?.popViewController(animated: true)
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
extension TodoAddViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return notesTextView.text.count + (text.count - range.length) <= MaxNumCharacters.maxNotes.rawValue
    }
}
// MARK: - UITextFieldDelegate
extension TodoAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let titleText = titleTextField.text ?? ""
        return titleText.count + (string.count - range.length) <= MaxNumCharacters.maxTitle.rawValue
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.transform = CGAffineTransform.identity
        }
    }
}
