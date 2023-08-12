//
//  settingItemModel.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/02.
//

import Foundation

// 設定画面のModel
struct SettingItem {
    let emoji: String
    let title: String
}
let settingItems: [SettingItem] = [
    SettingItem(emoji: "👀", title: R.string.localizable.accountUpgrade()),
    SettingItem(emoji: "✉️", title: R.string.localizable.contactUs()),
    SettingItem(emoji: "📝", title: R.string.localizable.privacyPolicy()),
    SettingItem(emoji: "✋", title: R.string.localizable.logout()),
    SettingItem(emoji: "🦭", title: R.string.localizable.deleteAccount())
]
