//
//  UserDefaults+.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation

extension UserDefaults {
    // ログインしてるかの判定
    private var loginedKey: String { "logined" }
    var isLogined: Bool {
        set {
            setValue(newValue, forKey: loginedKey)
        }
        get {
            bool(forKey: loginedKey)
        }
    }
    // アカウントをアップデートしてるかの判定
    private var isAuthAccountCreatedKey: String { "isAuthAccountCreated" }
    var isAuthAccountCreated: Bool {
        set {
            setValue(newValue, forKey: isAuthAccountCreatedKey)
        }
        get {
            bool(forKey: isAuthAccountCreatedKey)
        }
    }
}
