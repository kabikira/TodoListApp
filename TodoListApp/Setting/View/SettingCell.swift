//
//  SettingCell.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/02.
//

import UIKit

final class SettingCell: UITableViewCell {

    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    static var className: String { String(describing: SettingCell.self)}

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        titleLabel.text = nil
    }
    func configure(settingItem: SettingItem) {
        emojiLabel.text = settingItem.emoji
        titleLabel.text = settingItem.title
        accessoryType = .disclosureIndicator
    }
}
