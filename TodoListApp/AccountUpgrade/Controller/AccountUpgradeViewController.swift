//
//  AccountUpgradeViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/08.
//

import UIKit
import Firebase

class AccountUpgradeViewController: UIViewController {

    @IBOutlet private weak var AccountUpgradeLabel: UILabel! {
        didSet {
            // 多言語wrongEmailButton
        }
    }
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var registerSendMailButton: UIButton! {
        didSet {
            registerSendMailButton.setTitle(R.string.localizable.registerAndSendAnEmail(), for: .normal)
            registerSendMailButton.addTarget(self, action: #selector(tappedregisterSendMailButton), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var userNameTextField: UITextField!

    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(R.string.localizable.checkYourEmailAndLogIn(), for: .normal)
            loginButton.addTarget(self, action: #selector(tappedLoginBotton), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var wrongEmailButton: UIButton! {
        didSet {
            wrongEmailButton.setTitle(R.string.localizable.didYouEnterAWrongEmailAddress(), for: .normal)
            wrongEmailButton.addTarget(self, action: #selector(tappedwrongEmailButton), for: .touchUpInside)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }

}
// MARK: - Actions
private extension AccountUpgradeViewController {
    @objc func tappedregisterSendMailButton(_ sender: Any) {
        // メール送信成功時認証メールを確認するまで画面を遷移できなくする
        self.isModalInPresentation = true
        wrongEmailButton.isHidden = false
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        FirebaseUserManager.accountUpgrade(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                // ユーザー作成成功時に、userNameを設定
                FirebaseUserManager.registerUserName(userName: userName) { result in
                    switch result {
                    case .success():
                        print("userName作成成功")
                    case .failure(let error):
                        Alert.showErrorAlert(vc: self, error: error)
                    }
                }
                // メールを送信
                guard let user = FirebaseUserManager.getCurrentUser() else { return }
                FirebaseUserManager.sendEmailVerification(to: user)
                DispatchQueue.main.async {
                    Alert.okAlert(vc: self, title: R.string.localizable.emailSent(), message: R.string.localizable.pleaseAccessTheURLInTheEmail())
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
    // メールアドレス打ち間違い用メール再送信
    @objc func tappedwrongEmailButton(_ sender: Any) {
        Router.shared.showEmailUpdate(from: self)

    }
    @objc func tappedLoginBotton(_ sender: Any) {
        // mailをチェックしていたらログイン
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        FirebaseUserManager.checkAuthenticationEmail(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                
                // 認証アカウントのUserDefaultsをtrue
                UserDefaults.standard.isAuthAccountCreated = true
                print("メールチェック")
                DispatchQueue.main.async {
                    // TODO:
                    Alert.okAlert(vc: self, title: R.string.localizable.accountUpgrade(), message: R.string.localizable.verified()) { [weak self] result in
                        guard let self = self else { return }
                        self.dismiss(animated: true)
                    }
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
}
// MARK: - UITextFieldDelegate
extension AccountUpgradeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)

        switch textField {
        case emailTextField:
            return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
        case passwordTextField:
            return updatedTextLength <= MaxNumCharacters.maxPassword.rawValue
        case userNameTextField:
            return updatedTextLength <= MaxNumCharacters.maxUserName.rawValue
        default:
            return true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let userName = userNameTextField.text else { return }
        // 半角と全角のスペースを文字列から取り除く
        emailTextField.text = email.removingWhiteSpace()
        passwordTextField.text = password.removingWhiteSpace()
        userNameTextField.text = userName.removingWhiteSpace()
    }
}

