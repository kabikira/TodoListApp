//
//  LoginViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var anonymousLoginButton: UIButton! {
        didSet {
            anonymousLoginButton.setTitle(R.string.localizable.useWithoutCreatingAnAccount(), for: .normal)
            anonymousLoginButton.addTarget(self, action: #selector(tapedAnonymousLoginButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var loginLanel: UILabel! {
        didSet {
            loginLanel.text = R.string.localizable.login()
        }
    }
    @IBOutlet private weak var newRegistrationButton: UIButton! {
        didSet {
            newRegistrationButton.setTitle(R.string.localizable.signUpForANewAccount(), for: .normal)
            newRegistrationButton.addTarget(self, action: #selector(tapedNewRegistrationButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(R.string.localizable.login(), for: .normal)
            loginButton.addTarget(self, action: #selector(tapedLoginButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var passwordResetButton: UIButton! {
         didSet{
             passwordResetButton.setTitle(R.string.localizable.forgotPassword(), for: .normal)
             passwordResetButton.addTarget(self, action: #selector(tapedPasswordResetButton(_:)), for: .touchUpInside)
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
}
// MARK: - Actions
private extension LoginViewController {
    @objc func tapedNewRegistrationButton(_ sender: Any) {
        Router.shared.showNewRegistration(from: self)
    }
    @objc func tapedLoginButton(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        // ログイン処理
        FirebaseUserManager.singIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                // userDefaに値をいれる
                UserDefaults.standard.isLogined = true
                // 画面遷移TodoListへ
                Router.shared.showTodoList(from: self)
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
    @objc func tapedPasswordResetButton(_ sender: Any) {
        // パスワード送信画面に遷移
        Router.shared.showPasswordReset(from: self)
    }
    // 匿名ログイン
    @objc func tapedAnonymousLoginButton(_ sender: Any) {
        FirebaseUserManager.anonymousLogin { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            case.success():
                // userDefaに値をいれる
                UserDefaults.standard.isLogined = true
                UserDefaults.standard.isAuthAccountCreated = true
                // サンプルデータをTodoに入れる
                self.createTodosFromConstants()
                // 画面遷移TodoListへ
                Router.shared.showTodoList(from: self)
            }
        }
    }
    func createTodosFromConstants() {
        for i in 0..<TodoConstants.todosTypes.count {
            FirebaseDBManager.createTodo(
                title: TodoConstants.todosTitles[i],
                notes: TodoConstants.todosNotes[i],
                todos: TodoConstants.todosTypes[i]
            ) { result in
                switch result {
                case .success():
                    print("Successfully created \(TodoConstants.todosTypes[i]) database")
                case .failure(let error):
                    print("Failed to create \(TodoConstants.todosTypes[i]) database: \(error)")
                }
            }
        }
    }
}
// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)

        switch textField {
        case emailTextField:
            return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
        case passwordTextField:
            return updatedTextLength <= MaxNumCharacters.maxPassword.rawValue
        default:
            return true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        emailTextField.text = email.removingWhiteSpace()
        passwordTextField.text = password.removingWhiteSpace()
    }
}

