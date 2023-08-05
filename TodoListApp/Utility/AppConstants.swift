//
//  AppConstants.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import Firebase
enum MaxNumCharacters: Int {
    case maxEmail = 254
    case maxPassword = 32
    case maxUserName = 20
    case maxNotes = 140
    case maxTitle = 50
}
enum SettingItemCell: Int {
    case singOutCellRow = 3
    case withDrawCellRow = 4
}
enum URLs {
    static let googleForms = "https://docs.google.com/forms/d/e/1FAIpQLSfpFrJaXEElgvXTiovIgSMzstFfu5rATe4pc4L8lIe12MiXWw/viewform"
    static let privacyPolicy = "https://kabikira.github.io/imael.github.io/privacy/privacy.html"
}

struct ErrorHandling {
    static func firebaseErrorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        // エラー処理
        if let error = error as? AuthErrorCode {
            switch error.code {
            case .networkError: message = "ネットワークに接続できません"
            case .userNotFound: message = "ユーザが見つかりません"
            case .invalidEmail: message = "不正なメールアドレスです"
            case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
            case .wrongPassword: message = "入力した認証情報でサインインできません"
            case .userDisabled: message = "このアカウントは無効です"
            case .weakPassword: message = "パスワードが脆弱すぎます"
            default:
                print("unknown error")
            }
        }
        return message
    }
}


