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
    SettingItem(emoji: "👀", title: R.string.localizable.appDescription()),
    SettingItem(emoji: "✉️", title: R.string.localizable.contactUs()),
    SettingItem(emoji: "📝", title: R.string.localizable.privacyPolicy()),
    SettingItem(emoji: "✋", title: R.string.localizable.logout()),
    SettingItem(emoji: "🦭", title: R.string.localizable.deleteAccount())
]
