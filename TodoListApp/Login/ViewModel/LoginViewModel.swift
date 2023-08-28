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

}

protocol LoginViewModelOutput {
    // 匿名ログインButtonがタップされたら匿名ログインアカウントを作成して出力
    var createAnonymousAccountObeservable: Observable<Void> { get }
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

    // output
    private let _createAnonymousAccount = PublishRelay<Void>()
    lazy var createAnonymousAccountObeservable: Observable<Void> = _createAnonymousAccount.asObservable()

    private let _errorRelay = PublishRelay<Error>()
    lazy var errorObservable: Observable<Error> = _errorRelay.asObservable()

    init() {
        // 匿名ログインButtonのタップを監視し匿名Accountを作成
        _anonymousLoginButton
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                #if DEBUG
                print("匿名タップ")
                #endif
                // 匿名Account作成処理
                FirebaseUserManager.anonymousLogin { result in
                        switch result {
                        case.failure(let error):
                            #if DEBUG
                            print("ログイン失敗: \(error)")
                            #endif
                            self._errorRelay.accept(error)
                        case.success():
                            #if DEBUG
                            print("ログイン成功")
                            #endif
                            UserDefaults.standard.isLogined = true
                            UserDefaults.standard.isAuthAccountCreated = false
                            self.createTodosFromConstants()
                            self._createAnonymousAccount.accept(())
                        }
                }

            })
            .disposed(by: disposeBag)


    }
}
// TODO: - これはFirebaseDBManagerにあったほうがいいかな?
private extension LoginViewModel {
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
