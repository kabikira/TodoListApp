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

    let firebaseUserManager = FirebaseUserManager()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    


}
private extension PasswordResetViewController {
    @objc func tapedPasswordResetEmailButton(_ sender: Any) {
        // resetメール送信
        let email = emailTextField.text ?? ""
        firebaseUserManager.sendPasswordReset(email: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                // ､アラートかモダールかの処理
                print("リセットメール送信")
            case.failure(let error):
                self.showErrorAlert(error: error, vc: self)
            }

        }
    }
}
