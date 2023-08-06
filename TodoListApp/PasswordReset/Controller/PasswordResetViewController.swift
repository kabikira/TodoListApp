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
                DispatchQueue.main.async {
                    Alert.okAlert(vc: self, title: "Email sent.", message: "Please access the URL in the email")
                }
                print("リセットメール送信")
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
}
// MARK: - UITextFieldDelegate
extension PasswordResetViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)
        return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        emailTextField.text = email.removingWhiteSpace()
    }
}
