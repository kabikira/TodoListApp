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
