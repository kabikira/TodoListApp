//
//  NewRegistrationViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class NewRegistrationViewController: UIViewController {

    private let firebaseUserManager: FirebaseUserManagerProtocol

    init?(coder: NSCoder, firebaseUserManager: FirebaseUserManagerProtocol = FirebaseUserManager()) {
        self.firebaseUserManager = firebaseUserManager
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var wrongEmailButton: UIButton! {
        didSet {
            // 登録メール送信ボタンを押すまで隠す
            wrongEmailButton.isHidden = true
            wrongEmailButton.setTitle(R.string.localizable.didYouEnterAWrongEmailAddress(), for: .normal)
            wrongEmailButton.addTarget(self, action: #selector(tappedWrongEmailButton), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var newRegisterLabel: UILabel! {
        didSet {
            newRegisterLabel.text = R.string.localizable.newRegistration()
        }
    }
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    @IBOutlet weak var registerNameTextField: UITextField!
    @IBOutlet weak var registerSendMailButton: UIButton! {
        didSet {
            registerSendMailButton.setTitle(R.string.localizable.registerAndSendAnEmail(), for: .normal)
            registerSendMailButton.addTarget(self, action: #selector(tappedSendMail(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(R.string.localizable.checkYourEmailAndLogIn(), for: .normal)
            loginButton.addTarget(self, action: #selector(tappedLogin(_:)), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerEmailTextField.delegate = self
        registerPasswordTextField.delegate = self
        registerNameTextField.delegate = self
        // パスワードのテキストフィールドの入力値を隠し半角しか入力できないようにする
        registerPasswordTextField.isSecureTextEntry = true
    }
}
// MARK: - ButtonActions
extension NewRegistrationViewController {
    @objc func tappedSendMail(_ sender: Any) {
        // 送信ボタンを押したらwrongEmailButton出現
        wrongEmailButton.isHidden = false
        let email = registerEmailTextField.text ?? ""
        let password = registerPasswordTextField.text ?? ""
        let userName = registerNameTextField.text ?? ""

        // 最初にユーザーを作成
        self.firebaseUserManager.createUser(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                // ユーザー作成成功時に、userNameを設定
                self.firebaseUserManager.registerUserName(userName: userName) { result in
                    switch result {
                    case .success():
                        // サンプルデータをTodoに入れる
                        self.createTodosFromConstants()
                        // メールを送信
                        guard let user = self.firebaseUserManager.getCurrentUser() else { return }
                        self.firebaseUserManager.sendEmailVerification(to: user) { result in
                            switch result {
                            case.success():
                                DispatchQueue.main.async {
                                    Alert.okAlert(vc: self, title: R.string.localizable.emailSent(), message: R.string.localizable.pleaseAccessTheURLInTheEmail())
                                }
                            case.failure(let error):
                                DispatchQueue.main.async {
                                    Alert.showErrorAlert(vc: self, error: error)
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            Alert.showErrorAlert(vc: self, error: error)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
    @objc func tappedLogin(_ sender: Any) {
        // mailをチェックしていたらログイン ユーザデフォ
        let email = registerEmailTextField.text ?? ""
        let password = registerPasswordTextField.text ?? ""
        self.firebaseUserManager.checkAuthenticationEmail(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                // userDefaに値をいれる
                UserDefaults.standard.isLogined = true
                UserDefaults.standard.isAuthAccountCreated = true
                // todoへ画面遷移
                Router.shared.showTodoList(from: self)
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
        }
    }
    @objc func tappedWrongEmailButton() {
        // Email更新画面に遷移
        Router.shared.showEmailUpdate(from: self, isNewRegistration: true)
    }
    func createTodosFromConstants() {
        // ダミーのtodosを作る
        for i in 0..<TodoConstants.todosTypes.count {
            FirebaseDBManager.createTodo(
                title: TodoConstants.todosTitles[i],
                notes: TodoConstants.todosNotes[i],
                todos: TodoConstants.todosTypes[i]
            ) { result in
                switch result {
                case .success():
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        Alert.showErrorAlert(vc: self, error: error)
                    }
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewRegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 入力されたときの文字制限をチェック
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)

        switch textField {
        case registerEmailTextField:
            return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
        case registerPasswordTextField:
            return updatedTextLength <= MaxNumCharacters.maxPassword.rawValue
        case registerNameTextField:
            return updatedTextLength <= MaxNumCharacters.maxUserName.rawValue
        default:
            return true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = registerEmailTextField.text else { return }
        guard let password = registerPasswordTextField.text else { return }
        guard let userName = registerNameTextField.text else { return }
        // 半角と全角のスペースを文字列から取り除く
        registerEmailTextField.text = email.removingWhiteSpace()
        registerPasswordTextField.text = password.removingWhiteSpace()
        registerNameTextField.text = userName.removingWhiteSpace()
    }
}
