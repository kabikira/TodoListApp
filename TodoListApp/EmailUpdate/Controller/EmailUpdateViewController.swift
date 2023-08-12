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
            loginButton.setTitle(R.string.localizable.checkYourEmailAndLogIn(), for: .normal)
            loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var updateEmailButton: UIButton! {
        didSet {
            updateEmailButton.setTitle(R.string.localizable.updateYourEmailAddress(), for: .normal)
            updateEmailButton.addTarget(self, action: #selector(tappedUpdateEmailButton), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        // パスワードのテキストフィールドの入力値を隠し半角しか入力できないようにする
        passwordTextField.isSecureTextEntry = true
    }

}
// MARK: - ButtonACTION
private extension EmailUpdateViewController {
    @objc func tappedUpdateEmailButton() {
        // ボタンの連続タップを禁止
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
                    FirebaseUserManager.sendEmailVerification(to: user) { result in
                        switch result {
                        case.success():
                            DispatchQueue.main.async {
                                Alert.okAlert(vc: self, title: R.string.localizable.emailSent(), message: R.string.localizable.pleaseAccessTheURLInTheEmail())
                            }
                        case.failure(let error):
                            Alert.showErrorAlert(vc: self, error: error)
                        }
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
                    // TODO: - 新規登録のときのことを考えてないので修正
                    Alert.okAlert(vc: self, title: R.string.localizable.upgradeIsComplete(), message: R.string.localizable.verified()) { [weak self] _ in
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
        // 入力されたときの文字制限をチェック
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)
        return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        // 半角と全角のスペースを文字列から取り除く
        emailTextField.text = email.removingWhiteSpace()
    }
}

