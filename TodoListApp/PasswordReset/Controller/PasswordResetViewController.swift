//
//  PasswordResetViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/31.
//

import UIKit

class PasswordResetViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordResetEmailButton: UIButton! {
        didSet {
            passwordResetEmailButton.addTarget(self, action: #selector(tapedPasswordResetEmailButton(_:)), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self

    }
    


}
private extension PasswordResetViewController {
    @objc func tapedPasswordResetEmailButton(_ sender: Any) {
        // resetメール送信
        let email = emailTextField.text ?? ""
        FirebaseUserManager.sendPasswordReset(email: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                Alert.okAlert(vc: self, title: "Email sent.", message: "Please access the URL in the email")
                print("リセットメール送信")
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            }

        }
    }
}
extension PasswordResetViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        if email.count > MaxNumCharacters.maxEmail.rawValue {
            // 最大文字以上なら切り捨て
            emailTextField.text = String(email.prefix(MaxNumCharacters.maxEmail.rawValue))
        }
        emailTextField.text = email.removingWhiteSpace()
    }

}
