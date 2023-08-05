//
//  settingItemModel.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/02.
//

import Foundation

struct SettingItem {
    let emoji: String
    let title: String
}
// TODO: 仮の実装
let settingItems: [SettingItem] = [
    SettingItem(emoji: "👀", title: "アプリの説明"),
    SettingItem(emoji: "✉️", title: "お問い合わせ"),
    SettingItem(emoji: "📝", title: "プライバシーポリシー"),
    SettingItem(emoji: "✋", title: "ログアウト"),
    SettingItem(emoji: "✋", title: "退会")
]
