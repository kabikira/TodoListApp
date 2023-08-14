//
//  AppConstants.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import Firebase
// FirebaseCollectionに使う定数
struct FirebaseCollections {
    static let user = "user"
    enum Todos: String {
        case todosFirst
        case todosSecond
        case todosThird
        case todosFourth
    }
}
// todosの詳細
struct FirebaseFields {
    enum TodosItem: String {
        case title
        case notes
        case isDone
        case createdAt
        case updatedAt
    }
}
// 最初に入れるtodoリストのテストデータ
struct TodoConstants {
    static let todosTitles = ["First Todo", "Second Todo", "Third Todo", "Fourth Todo"]
    static let todosNotes = ["Notes for First Todo", "Notes for Second Todo", "Notes for Third Todo", "Notes for Fourth Todo"]
    static let todosTypes = [FirebaseCollections.Todos.todosFirst.rawValue,
                             FirebaseCollections.Todos.todosSecond.rawValue,
                             FirebaseCollections.Todos.todosThird.rawValue,
                             FirebaseCollections.Todos.todosFourth.rawValue]
}

// TextFiledの文字制限に使う
enum MaxNumCharacters: Int {
    case maxEmail = 254
    case maxPassword = 32
    case maxUserName = 20
    case maxNotes = 140
    case maxTitle = 50
}
// SettingViewのセルの番号
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
// アプリで使用するURL
enum URLs {
    static let googleForms = "https://docs.google.com/forms/d/e/1FAIpQLSfpFrJaXEElgvXTiovIgSMzstFfu5rATe4pc4L8lIe12MiXWw/viewform"
    static let privacyPolicy = "https://kabikira.github.io/imael.github.io/privacy/privacy.html"
}


