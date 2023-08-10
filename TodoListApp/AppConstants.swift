//
//  AppConstants.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import Firebase

struct FirebaseCollections {
    static let user = "user"
    enum Todos: String {
        case todosFirst
        case todosSecond
        case todosThird
        case todosFourth
    }
}
struct FirebaseFields {
    enum TodosItem: String {
        case title
        case notes
        case isDone
        case createdAt
        case updatedAt
    }
}
// 最初に入れるダミーデータ
struct TodoConstants {
    static let todosTitles = ["First Todo", "Second Todo", "Third Todo", "Fourth Todo"]
    static let todosNotes = ["Notes for First Todo", "Notes for Second Todo", "Notes for Third Todo", "Notes for Fourth Todo"]
    static let todosTypes = [FirebaseCollections.Todos.todosFirst.rawValue,
                             FirebaseCollections.Todos.todosSecond.rawValue,
                             FirebaseCollections.Todos.todosThird.rawValue,
                             FirebaseCollections.Todos.todosFourth.rawValue]
}


enum MaxNumCharacters: Int {
    case maxEmail = 254
    case maxPassword = 32
    case maxUserName = 20
    case maxNotes = 140
    case maxTitle = 50
}
enum SettingItemCell: Int {
    case AccountUpgrade = 0
    case singOutCellRow = 3
    case withDrawCellRow = 4
}
struct ImageNames {
    static let checkmarkCircle = "checkmark.circle"
    static let circle = "circle"
    static let gearshape = "gearshape"
}

enum URLs {
    static let googleForms = "https://docs.google.com/forms/d/e/1FAIpQLSfpFrJaXEElgvXTiovIgSMzstFfu5rATe4pc4L8lIe12MiXWw/viewform"
    static let privacyPolicy = "https://kabikira.github.io/imael.github.io/privacy/privacy.html"
}
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

