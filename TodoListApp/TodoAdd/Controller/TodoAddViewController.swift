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
    // Routre から呼び出されどのTodoリストカテゴリに属しているかを知る
    // TODO: func configure はどこからでも呼べるので修正したほうがいいかもしれない
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
        // Doneボタンでtodo編集してセルを更新させてとじる
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.done(), style: .done, target: self, action: #selector(tapedDoneBotton(_:)))
        // 閉じるボタン
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localizable.cancel(), style: .plain, target: self, action: #selector(tapedCancelBotton(_:)))

    }
}
// MARK: - BottonActions
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
                    break
                case .failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
        // Todo一覧画面に戻る処理
        self.navigationController?.popViewController(animated: true)
    }
    // 1つまえの画面に戻る
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
        // 入力されたときの文字制限をチェック
        return notesTextView.text.count + (text.count - range.length) <= MaxNumCharacters.maxNotes.rawValue
    }
}
// MARK: - UITextFieldDelegate
extension TodoAddViewController: UITextFieldDelegate {
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
