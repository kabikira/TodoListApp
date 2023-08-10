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
    // MARK: - 匿名ログイン
   static func anonymousLogin(completion: @escaping(Result<Void, NSError>) -> Void) {
        Auth.auth().signInAnonymously() { result, error  in
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                guard let user = result?.user else { return }
                print(user.uid)
                completion(.success)
            }
        }
    }
    // MARK: - アカウントアップグレード
    static func accountUpgrade(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.link(with: credential) { result, error in
                if let error = error {
                    // エラーが発生した場合の処理
                    completion(.failure(error))
                    return
                }
                // エラーがない場合、成功として処理
                guard let user = result?.user else { return }
                completion(.success(user))
            }
        } else {
            // 期待するユーザー状態ではない場合のエラー
            completion(.failure(NSError(domain: "com.example.firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not an anonymous user or user is nil."])))
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
                        completion(.success(()))
                    }
                }
            } else {
                print("error")
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
    // MARK: - ログインユーザーを取得
    static func getCurrentUser() -> User? {
            return Auth.auth().currentUser
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
    // MARK: - ログアウト
    static func singOut(completion: @escaping (Result<Void, NSError>) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            completion(.failure(error as NSError))
        }
        completion(.success)
    }
    // MARK: - 退会
    static func withDarw(completion: @escaping(Result<Void, NSError>) -> Void) {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                completion(.success)
            }
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
