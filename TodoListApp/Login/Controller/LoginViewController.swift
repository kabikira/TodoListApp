//
//  LoginViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var loginLanel: UILabel!
    @IBOutlet private weak var newRegistrationButton: UIButton! {
        didSet {
            newRegistrationButton.addTarget(self, action: #selector(tapedNewRegistrationButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(tapedLoginButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var passwordResetButton: UIButton! {
         didSet{
             passwordResetButton.addTarget(self, action: #selector(tapedPasswordResetButton(_:)), for: .touchUpInside)
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    
    
}
private extension LoginViewController {
    @objc func tapedNewRegistrationButton(_ sender: Any) {
        Router.shared.showNewRegistration(form: self)
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
                Alert.showErrorAlert(vc: self, error: error)
            }
        }
        
    }
    @objc func tapedPasswordResetButton(_ sender: Any) {
        // パスワード送信画面に遷移
        Router.shared.showPasswordReset(form: self)
    }
    
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        if email.count > MaxNumCharacters.maxEmail.rawValue {
            // 最大文字以上なら切り捨て
            emailTextField.text = String(email.prefix(MaxNumCharacters.maxEmail.rawValue))
        }
        emailTextField.text = email.removingWhiteSpace()

        if password.count > MaxNumCharacters.maxPassword.rawValue {
            passwordTextField.text = String(password.prefix(MaxNumCharacters.maxPassword.rawValue))
        }
        passwordTextField.text = password.removingWhiteSpace()
    }
}
