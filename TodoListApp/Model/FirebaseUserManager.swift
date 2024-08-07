//
//  FirebaseUserManager.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import FirebaseAuth
import RxSwift

protocol FirebaseUserManagerProtocol {
     func createUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
     func registerUserName(userName: String, completion: @escaping (Result<Void, Error>) -> Void)
     func anonymousLogin(completion: @escaping (Result<Void, Error>) -> Void)
     func accountUpgrade(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
     func updateEmail(to newEmail: String, completion: @escaping (Result<Void, Error>) -> Void)
     func sendEmailVerification(to user: User, completion: @escaping (Result<Void, Error>) -> Void)
     func checkAuthenticationEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
     func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void)
     func getCurrentUser() -> User?
     func singOut(completion: @escaping (Result<Void, Error>) -> Void)
     func withDarw(completion: @escaping(Result<Void, Error>) -> Void)
     func rxSignIn(email: String, password: String) -> Observable<Result<Void, Error>>
}

final class FirebaseUserManager {
    // MARK: - アカウント作成機能
    static func createUser(email: String, password: String, completion: @escaping(Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }

    // MARK: - UserNameを登録
    static func registerUserName(userName: String, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = userName
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // MARK: - 匿名ログイン
    static func anonymousLogin(completion: @escaping(Result<Void, Error>) -> Void) {
        Auth.auth().signInAnonymously() { result, error  in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    // MARK: - アカウントアップグレード
    static func accountUpgrade(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.link(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success)
            }
        } else {
            // 期待するユーザー状態ではない場合のエラー
            completion(.failure(ErrorHandling.TodoError.notAnAnonymousUserOrUserIsNil))
        }
    }

    // MARK: - emailの更新
    static func updateEmail(to newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 現在のログインユーザーを取得
        if let user = Auth.auth().currentUser {
            // メールアドレスを更新
            user.updateEmail(to: newEmail) { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // errorを伝えたいならResultのほうがいいかな?
    static func sendEmailVerification(to user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        user.sendEmailVerification { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }

    // MARK: - 登録認証のメールのURLを確認したか
    static func  checkAuthenticationEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let user = result?.user else { return }
                if user.isEmailVerified {
                    completion(.success)
                } else {
                    completion(.failure(ErrorHandling.TodoError.emailNotVerified))
                }
            }
        }
    }
    // MARK: - パスワード再設定案内のメール送信
    static func sendPasswordReset(email: String, completion: @escaping (Result<(), Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    // MARK: - ログインユーザーを取得
    static func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    // MARK: - ログアウト
    static func singOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            completion(.failure(error))
        }
        completion(.success)
    }
    // MARK: - 退会
    static func withDarw(completion: @escaping(Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
}

extension FirebaseUserManager: ReactiveCompatible {}
extension Reactive where Base: FirebaseUserManager {
    // MARK: - ログイン機能
    static func rxSignIn(email: String, password: String) -> Observable<Result<Void, Error>> {
        return Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onNext(.failure(error))
                } else {
                    observer.onNext(.success(()))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
///
///Success型がVoidであるときスッキリかける拡張
/// Usage:
///
/// Instead of writing:
///
/// ```swift
/// completion(.success(()))
/// ```
///
/// With this extension, you can simply write:
///
/// ```swift
/// completion(.success)
/// ```
extension Result where Success == Void {
    public static var success: Result { .success(()) }
}
