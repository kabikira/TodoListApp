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

    @IBOutlet private weak var anonymousLoginButton: UIButton! {
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
        }
    }
    @IBOutlet private(set) weak var passwordResetButton: UIButton! {
        didSet{
            passwordResetButton.setTitle(R.string.localizable.forgotPassword(), for: .normal)
        }
    }

//    private var viewModel: LoginViewModel!
//    private var router: RouterProtocol!
    var viewModel: LoginViewModel = LoginViewModel()
    var router: RouterProtocol = Router.shared

    private lazy var input: LoginViewModelInput = viewModel
    private lazy var output: LoginViewModelOutput = viewModel

    func inject(viewModel: LoginViewModel, router: RouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        self.input = viewModel
        self.output = viewModel
        print("Dependencies injected: viewModel and router are set")

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")

        passwordTextField.isSecureTextEntry = true
        bindInputStream()
        bindOutputStream()
    }

    private func bindInputStream() {
        let anonymousLoginButtonObservable = anonymousLoginButton.rx.tap.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        let passwordResetButtonObservable = passwordResetButton.rx.tap.asObservable()
            // 特定の時間内に最後のイベントのみを受け取る
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        let newRegistrationButtonObservable = newRegistrationButton.rx.tap.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        let loginButtonObservable = loginButton.rx.tap.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)

        rx.disposeBag.insert([
            anonymousLoginButtonObservable.bind(to: input.anonymousLoginButtonObserver),
            passwordResetButtonObservable.bind(to: input.passwordResetButtonObserver),
            newRegistrationButtonObservable.bind(to: input.newRegistrationButtonObserver),
            loginButtonObservable.bind(to: input.loginButtonObserver)
        ])

        emailTextField.rx.text.orEmpty
            .map { $0.removingWhiteSpace() }
            .filter { $0.count <= MaxNumCharacters.maxEmail.rawValue }
            .bind(to: input.emailTextObserver)
            .disposed(by: rx.disposeBag)

        passwordTextField.rx.text.orEmpty
            .map { $0.removingWhiteSpace() }
            .filter { $0.count <= MaxNumCharacters.maxEmail.rawValue }
            .bind(to: input.passwordTextObservr)
            .disposed(by: rx.disposeBag)
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
                router.showPasswordReset(from: self)
            })
            .disposed(by: rx.disposeBag)

        output.newRegistrationObservable.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                Router.shared.showNewRegistration(from: self)
            })
            .disposed(by: rx.disposeBag)

        output.loginSuccessObservable.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                Router.shared.showTodoList(from: self)
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
