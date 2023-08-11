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
        loginButton.isUserInteractionEnabled = false
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
            self.loginButton.isUserInteractionEnabled = true
        }
    }
    @objc func tapedPasswordResetButton(_ sender: Any) {
        // パスワード送信画面に遷移
        Router.shared.showPasswordReset(from: self)
    }
    // 匿名ログイン
    @objc func tapedAnonymousLoginButton(_ sender: Any) {
        anonymousLoginButton.isUserInteractionEnabled = false
        FirebaseUserManager.anonymousLogin { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                case.success():
                    // userDefaに値をいれる
                    UserDefaults.standard.isLogined = true
                    UserDefaults.standard.isAuthAccountCreated = false
                    // サンプルデータをTodoに入れる
                    self.createTodosFromConstants()
                    // 画面遷移TodoListへ
                    Router.shared.showTodoList(from: self)
                    Alert.okAlert(vc: self, title: "一時的なアカウントです", message: "データの永続性を保証できません。アカウントのデータを保持したい場合は、正式なアカウント登録をお勧めします。")
                }
                self.anonymousLoginButton.isUserInteractionEnabled = true
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
        // 半角と全角のスペースを文字列から取り除く
        emailTextField.text = email.removingWhiteSpace()
        passwordTextField.text = password.removingWhiteSpace()
        // ASCIIの範囲外の文字を取り除く(全角文字を取り除く)
        emailTextField.text = email.removingNonASCII()
        passwordTextField.text = password.removingNonASCII()
    }
}

