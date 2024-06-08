//
//  LoginViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class LoginViewController: UIViewController {

    @IBOutlet weak var anonymousLoginButton: UIButton! {
        didSet {
            anonymousLoginButton.setTitle(R.string.localizable.useWithoutCreatingAnAccount(), for: .normal)
        }
    }
    @IBOutlet private weak var loginLabel: UILabel! {
        didSet {
            loginLabel.text = R.string.localizable.login()
        }
    }
    @IBOutlet private weak var newRegistrationButton: UIButton! {
        didSet {
            newRegistrationButton.setTitle(R.string.localizable.signUpForANewAccount(), for: .normal)
        }
    }
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(R.string.localizable.login(), for: .normal)
            loginButton.addTarget(self, action: #selector(tapedLoginButton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var passwordResetButton: UIButton! {
        didSet{
            passwordResetButton.setTitle(R.string.localizable.forgotPassword(), for: .normal)
        }
    }

    private let viewModel = LoginViewModel()
    private lazy var input: LoginViewModelInput = viewModel
    private lazy var output: LoginViewModelOutput = viewModel
    

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        bindInputStream()
        bindOutputStream()
    }

    private func bindInputStream() {
        let anonymousLoginButtonObservable = anonymousLoginButton.rx.tap.asObservable()
            // 5秒間タップイベント無視
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        rx.disposeBag.insert([
            anonymousLoginButtonObservable.bind(to: input.anonymousLoginButtonObserver)
        ])

        let passwordResetButtonObservable = passwordResetButton.rx.tap.asObservable()
            // 特定の時間内に最後のイベントのみを受け取る
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        rx.disposeBag.insert([
            passwordResetButtonObservable.bind(to: input.passwordResetButtonObserver)
        ])

        let newRegistrationButtonObservable = newRegistrationButton.rx.tap.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        rx.disposeBag.insert([
            newRegistrationButtonObservable.bind(to: input.newRegistrationButtonObserver)
        ])
    }

    private func bindOutputStream() {
        output.createAnonymousAccountObservable.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                // 画面遷移TodoListへ
                Router.shared.showTodoList(from: self)
                Alert.okAlert(vc: self, title: R.string.localizable.temporaryAccount(), message: R.string.localizable.weCannotGuaranteeDataPermanenceIfYouWishToRetainTheDataInYourAccountWeRecommendThatYouRegisterForAFormalAccount())
            })
            .disposed(by: rx.disposeBag)

        output.passwordResetObservable.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                Router.shared.showPasswordReset(from: self)
            })
            .disposed(by: rx.disposeBag)

        output.newRegistrationObservable.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                Router.shared.showNewRegistration(from: self)
            })
            .disposed(by: rx.disposeBag)

        output.errorObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] error in
                guard let self else { return }
                Alert.showErrorAlert(vc: self, error: error)
            })
            .disposed(by: rx.disposeBag)
    }
}
// MARK: - ButtonActions
private extension LoginViewController {
    @objc func tapedLoginButton(_ sender: Any) {
        // ボタンの連続タップを防止
        loginButton.isUserInteractionEnabled = false
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        // ログイン処理
        FirebaseUserManager.singIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                // userDefaに値をいれる
                UserDefaults.standard.isLogined = true
                // 画面遷移TodoListへ
                Router.shared.showTodoList(from: self)
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
            }
            self.loginButton.isUserInteractionEnabled = true
        }
    }
}
// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 入力されたときの文字制限をチェック
        let currentText = textField.text ?? ""
        let updatedTextLength = currentText.count + (string.count - range.length)

        switch textField {
        case emailTextField:
            return updatedTextLength <= MaxNumCharacters.maxEmail.rawValue
        case passwordTextField:
            return updatedTextLength <= MaxNumCharacters.maxPassword.rawValue
        default:
            return true
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        // 半角と全角のスペースを文字列から取り除く
        emailTextField.text = email.removingWhiteSpace()
        passwordTextField.text = password.removingWhiteSpace()
    }
}

