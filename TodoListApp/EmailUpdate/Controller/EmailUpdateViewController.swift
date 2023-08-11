//
//  EmailUpdateViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/09.
//

import UIKit

class EmailUpdateViewController: UIViewController {


    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var updateEmailButton: UIButton! {
        didSet {
            updateEmailButton.addTarget(self, action: #selector(tappedUpdateEmailButton), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.isModalInPresentation = true
        emailTextField.delegate = self
    }

}
// MARK: - ACTION
private extension EmailUpdateViewController {
    @objc func tappedUpdateEmailButton() {
        updateEmailButton.isUserInteractionEnabled = false
        let email = emailTextField.text ?? ""
            // メールアドレスを更新
            FirebaseUserManager.updateEmail(to: email) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success():
                    print("メールアドレス更新成功")
                    guard let user = FirebaseUserManager.getCurrentUser() else { return }
                    // mail送信
                    FirebaseUserManager.sendEmailVerification(to: user)
                    DispatchQueue.main.async {
                        Alert.okAlert(vc: self, title: R.string.localizable.emailSent(), message: R.string.localizable.pleaseAccessTheURLInTheEmail())
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        Alert.showErrorAlert(vc: self, error: error)
                    }
                }
                self.updateEmailButton.isUserInteractionEnabled = true
            }
    }
    @objc func tappedLoginButton() {
        // mailをチェックしていたらログイン
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        FirebaseUserManager.checkAuthenticationEmail(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                print("メールチェック")
                // UserDefaultsに値を入れる
                UserDefaults.standard.isAuthAccountCreated = true
                DispatchQueue.main.async {
                    Alert.okAlert(vc: self, title: "アカウントアップグレード", message: "認証しました") { [weak self] _ in
                        guard let self = self else { return }
                        // モダール画面を2画面を1度に閉じる
                        //  まず遷移元のViewControllerを定数に入れる
                        let firstPresentingVC = self.presentingViewController
                        // 現在のモダールを閉じる
                        self.dismiss(animated: true) {
                            // 遷移元のモダールを閉じる
                            firstPresentingVC?.dismiss(animated: true)
                        }
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
extension EmailUpdateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)
        return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        // 半角と全角のスペースを文字列から取り除く
        emailTextField.text = email.removingWhiteSpace()
        // ASCIIの範囲外の文字を取り除く(全角文字を取り除く)
        emailTextField.text = email.removingNonASCII()
    }
}

