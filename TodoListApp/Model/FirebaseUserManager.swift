//
//  FirebaseUserManager.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import FirebaseAuth

final class FirebaseUserManager {
    // MARK: - アカウント作成機能
   static func createUser(email: String, password: String, completion: @escaping(Result<User, NSError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                completion(.failure(error))
            } else {
                guard let user = result?.user else { return }
                completion(.success(user))
            }
        }
    }
    // MARK: - ログイン機能
    static func singIn(email: String, password: String, completion: @escaping (Result<Void, NSError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error as NSError? {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }

    // MARK: - 登録認証のメール送信
//    func sendEmailVerification(to user: User, completion: @escaping (Result<Void, NSError>) -> Void) {
//        user.sendEmailVerification() { error in
//            if let error = error as NSError? {
//                completion(.failure(error))
//            } else {
//                completion(.success)
//            }
//        }
//    }
    // errorを伝えたいならResultのほうがいいかな?
    static func sendEmailVerification(to user: User) {
        user.sendEmailVerification()
        print("mail送信")
    }
    // MARK: - 登録認証のメールのURLを確認したか
    static func  checkAuthenticationEmail(email: String, password: String, completion: @escaping (Result<Void, NSError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error as NSError? {
                    completion(.failure(error))
                } else {
                    guard let user = result?.user else { return }
                    if user.isEmailVerified {
                        completion(.success)
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not verified"])))
                    }
                }
            }
    }
    // MARK: - パスワード再設定案内のメール送信
    static func sendPasswordReset(email: String, completion: @escaping (Result<(), NSError>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                completion(.success(()))
            }
        }
    }
    // MARK: - ログイン状態をチェック
    static func checkIsLogin(completion: () -> Void) {
        if Auth.auth().currentUser != nil {
            completion()
        }
    }
    // MARK: - ログアウト状態をチェック
    static func checkIsLogout(completion: () -> Void) {
        if Auth.auth().currentUser == nil {
            completion()
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
