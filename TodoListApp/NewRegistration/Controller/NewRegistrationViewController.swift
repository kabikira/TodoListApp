//
//  NewRegistrationViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class NewRegistrationViewController: UIViewController {
    
    @IBOutlet private weak var newRegisterLabel: UILabel!
    @IBOutlet private weak var registerEmailTextField: UITextField!
    @IBOutlet private weak var registerPasswordTextField: UITextField!
    @IBOutlet private weak var registerNameTextField: UITextField!
    @IBOutlet private weak var registerSendMailButton: UIButton! {
        didSet {
            registerSendMailButton.addTarget(self, action: #selector(tappedSendMail(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(tappedLogin(_:)), for: .touchUpInside)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        registerEmailTextField.delegate = self
        registerPasswordTextField.delegate = self
        registerNameTextField.delegate = self
    }

}
// MARK: - Actions
private extension NewRegistrationViewController {
    @objc func tappedSendMail(_ sender: Any) {
        let email = registerEmailTextField.text ?? ""
        let password = registerPasswordTextField.text ?? ""
        //  user登録してメールを送信
        FirebaseUserManager.createUser(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let user):
                print("登録成功")
                //TODO: Resultになおしてエラー処理書いたほうがいいかも
                FirebaseUserManager.sendEmailVerification(to:user)
                DispatchQueue.main.async {
                    Alert.okAlert(vc: self, title: "Email sent.", message: "Please access the URL in the email")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
    @objc func tappedLogin(_ sender: Any) {
        // mailをチェックしていたらログイン ユーザデフォ
        let email = registerEmailTextField.text ?? ""
        let password = registerPasswordTextField.text ?? ""
        FirebaseUserManager.checkAuthenticationEmail(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                print("メールチェック")
                // userDefaに値をいれる
                UserDefaults.standard.isLogined = true
                //TODO: Todosを4つ作成､この処理を切り分ける､仮のタイトル､notes入力ユーザにわかりやすい例をいれておく
                let todosTitles = ["First Todo", "Second Todo", "Third Todo", "Fourth Todo"]
                let todosNotes = ["Notes for First Todo", "Notes for Second Todo", "Notes for Third Todo", "Notes for Fourth Todo"]
                let todosTypes = [FirebaseCollections.Todos.todosFirst.rawValue,
                                  FirebaseCollections.Todos.todosSecond.rawValue,
                                  FirebaseCollections.Todos.todosThird.rawValue,
                                  FirebaseCollections.Todos.todosFourth.rawValue]

                for i in 0..<todosTypes.count {
                    FirebaseDBManager.createTodo(title: todosTitles[i], notes: todosNotes[i], todos: todosTypes[i]) { result in
                        switch result {
                        case .success():
                            print("Successfully created \(todosTypes[i]) database")
                        case .failure(let error):
                            print("Failed to create \(todosTypes[i]) database: \(error)")
                        }
                    }
                }
                // loginへ画面遷移
                Router.shared.showTodoList(from: self)
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }

        }

    }
}

// MARK: - UITextFieldDelegate
extension NewRegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)

        switch textField {
        case registerEmailTextField:
            return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
        case registerPasswordTextField:
            return updatedTextLength <= MaxNumCharacters.maxPassword.rawValue
        case registerNameTextField:
            return updatedTextLength <= MaxNumCharacters.maxUserName.rawValue
        default:
            return true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = registerEmailTextField.text else { return }
        guard let password = registerPasswordTextField.text else { return }
        guard let userName = registerNameTextField.text else { return }
        registerEmailTextField.text = email.removingWhiteSpace()
        registerPasswordTextField.text = password.removingWhiteSpace()
        registerNameTextField.text = userName.removingWhiteSpace()
    }
}
