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
