//
//  TodoListViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoListViewController: UIViewController {

    private var todoItems: [TodoItemModel] = []
    private var isDone: Bool = false


    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: TodoListViewCell.className, bundle: nil), forCellReuseIdentifier: TodoListViewCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var changeTodosControl: UISegmentedControl!
    @IBOutlet private weak var addTaskButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 完了済みを非表示にするボタン
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            primaryAction: UIAction { [weak self] _ in
                guard let self = self else { return }
                // TODO: アラート処理で選ぶ
//                self.repository.toggleVisbility()
//                self.applySnapshot()
            })
        navigationItem.title = "TodoList"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: "gearshape"), style: .done, target: self, action: nil)

    }

}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Router.shared.showTodoEdit(from: self, todoItems: todoItems[indexPath.row])
    }

}
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListViewCell.className) as? TodoListViewCell else { fatalError() }
        let item = todoItems[indexPath.row]
        cell.configure(todoItem: item)
        return cell
    }

}
