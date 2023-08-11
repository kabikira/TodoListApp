//
//  ErrorHandling.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/12.
//

import Foundation
import Firebase
// Firebaseのエラーハンドリング
struct ErrorHandling {
    static func firebaseErrorMessage(of error: Error) -> String {
        var message = R.string.localizable.generalError()
        // エラー処理
        if let error = error as? AuthErrorCode {
            switch error.code {
            case .networkError: message = R.string.localizable.networkError()
            case .userNotFound: message = R.string.localizable.userNotFoundError()
            case .invalidEmail: message = R.string.localizable.invalidEmailError()
            case .emailAlreadyInUse: message = R.string.localizable.emailInUseError()
            case .wrongPassword: message = R.string.localizable.wrongPasswordError()
            case .userDisabled: message = R.string.localizable.userDisabledError()
            case .weakPassword: message = R.string.localizable.weakPasswordError()
            default:
                print("unknown error")
            }
        }
        return message
    }
}
