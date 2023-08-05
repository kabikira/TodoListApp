//
//  TodoAddViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoAddViewController: UIViewController {

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!



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
        navigationItem.title = "AddTodo"
        // TODO: Doneでtodo編集してセルを更新させてとじる
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tapedDoneBotton(_:)))
        // TODO: 閉じる
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tapedCancelBotton(_:)))

    }
}
// MARK: - Actions
private extension TodoAddViewController {
    @objc func tapedDoneBotton(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let notes = notesTextView.text ?? ""
        // ログイン済みか確認 // FirestoreにTodoデータを作成する
        FirebaseDBManager.createTodo(title: title, notes: notes) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                print("データベース作成")
//                NotificationCenter.default.post(name: .updateTodoListView, object: nil)
               
            case .failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            }
        }
        // Todo一覧画面に戻る処理
        self.navigationController?.popViewController(animated: true)
    }
    @objc func tapedCancelBotton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
// MARK: - UITextViewDelegate
extension TodoAddViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return notesTextView.text.count + (text.count - range.length) <= MaxNumCharacters.maxNotes.rawValue
    }
}
extension TodoAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let titleText = titleTextField.text ?? ""
        return titleText.count + (string.count - range.length) <= MaxNumCharacters.maxTitle.rawValue
    }
}
