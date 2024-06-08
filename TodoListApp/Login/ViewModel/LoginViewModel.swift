//
//  LoginViewModel.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/28.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

protocol LoginViewModelInput {
    // 匿名ログインButtonのタップを受け取る
    var anonymousLoginButtonObserver: AnyObserver<Void> { get }
    // ログインButtonのタップを受け取る
    var loginButtonObserver: AnyObserver<Void> { get }
}

protocol LoginViewModelOutput {
    // 匿名ログインButtonがタップされたら匿名ログインアカウントを作成して出力
    var createAnonymousAccountObservable: Observable<Void> { get }
    // ログインButtonがタップされたらログインアカウントを作成して出力
    var createAccountObservable: Observable<Void> { get }
    // エラーを伝達するためのObservable
    var errorObservable: Observable<Error> { get }
}

final class LoginViewModel: LoginViewModelInput, LoginViewModelOutput, HasDisposeBag {
    // input
    private let _anonymousLoginButton = PublishRelay<Void>()
    lazy var anonymousLoginButtonObserver: AnyObserver<Void> = .init(eventHandler: { (event) in
        guard let e = event.element else { return }
        self._anonymousLoginButton.accept(e)
    })

    private let _loginButton = PublishRelay<Void>()
    lazy var loginButtonObserver: AnyObserver<Void> = .init(eventHandler: { (event) in
        guard let e = event.element else { return}
        self._loginButton.accept(e)
    })

    // output
    private let _createAnonymousAccount = PublishRelay<Void>()
    lazy var createAnonymousAccountObservable: Observable<Void> = _createAnonymousAccount.asObservable()

    private let _createAccount = PublishRelay<Void>()
    lazy var createAccountObservable: Observable<Void> = _createAccount.asObservable()

    private let _errorRelay = PublishRelay<Error>()
    lazy var errorObservable: Observable<Error> = _errorRelay.asObservable()

    init() {
        setupBindings()
    }
}
// TODO: - これはFirebaseDBManagerにあったほうがいいかな?
private extension LoginViewModel {

    // 内部実装の詳細はプロトコルに含めない
    func setupBindings() {
        _anonymousLoginButton
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                FirebaseUserManager.anonymousLogin { result in
                    switch result {
                    case .failure(let error):

                        self._errorRelay.accept(error)
                    case .success:

                        UserDefaults.standard.isLogined = true
                        UserDefaults.standard.isAuthAccountCreated = false
                        self.createTodosFromConstants()
                        self._createAnonymousAccount.accept(())
                    }
                }
            })
            .disposed(by: disposeBag)

        _loginButton
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // ログイン処理をここに追加
            })
            .disposed(by: disposeBag)
    }

    // サンプルデータをTodoに入れる
    func createTodosFromConstants() {
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
                    self._errorRelay.accept(error)

                }
            }
        }
    }
}
