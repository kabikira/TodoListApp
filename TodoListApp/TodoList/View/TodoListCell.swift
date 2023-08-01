//
//  TodoListCell.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

final class TodoListViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!

    // ハードコーティングを防ぐため
    static var className: String { String(describing: TodoListViewCell.self)}

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        notesLabel.text = nil
    }
    func configure(todoItem: TodoItemModel) {
        titleLabel.text = todoItem.title
        notesLabel.text = todoItem.notes
    }

}
