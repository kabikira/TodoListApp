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
                Alert.okAlert(vc: self, title: "Email sent.", message: "Please access the URL in the email")
            case .failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
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
                // loginへ画面遷移
                Router.shared.showTodoList(from: self)
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            }

        }

    }
}

// MARK: - UITextFieldDelegate
extension NewRegistrationViewController: UITextFieldDelegate {
    // テキストフィールドのセレクションが変更された時に処理を行う
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = registerEmailTextField.text else { return }
        guard let password = registerPasswordTextField.text else { return }
        guard let userName = registerNameTextField.text else { return }
        if email.count > MaxNumCharacters.maxEmail.rawValue {
            // 最大文字以上なら切り捨て
            print(MaxNumCharacters.maxEmail.rawValue)
            registerEmailTextField.text = String(email.prefix(MaxNumCharacters.maxEmail.rawValue))
        }
        registerEmailTextField.text = email.removingWhiteSpace()
        if password.count > MaxNumCharacters.maxPassword.rawValue {
            registerPasswordTextField.text = String(password.prefix(MaxNumCharacters.maxPassword.rawValue))
        }
        registerPasswordTextField.text = password.removingWhiteSpace()
        if userName.count > MaxNumCharacters.maxUserName.rawValue {
            registerNameTextField.text = String(password.prefix(MaxNumCharacters.maxUserName.rawValue))
        }
        registerNameTextField.text = userName.removingWhiteSpace()
    }
}
