//
//  TodoListViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoListViewController: UIViewController {

    private var todoItems: [TodoItemModel] = []
    private var showingDone = true


    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: TodoListCell.className, bundle: nil), forCellReuseIdentifier: TodoListCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var changeTodosControl: UISegmentedControl!
    @IBOutlet private weak var addTaskButton: UIButton! {
        didSet {
            addTaskButton.addTarget(self, action: #selector(tapedAddBotton(_:)), for: .touchUpInside)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // ビューが表示されるときにデータをリロード
            reloadData()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 完了済みを非表示にするボタン
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: UIImage(systemName: showingDone ? "checkmark.circle" : "circle"),
                    style: .plain,
                    target: self,
                    action: #selector(toggleTodoStatus)
                )
        navigationItem.title = "TodoList"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(tapedLeftBarButton(_:)))
        // 通知を受け取りリロード
//        NotificationCenter.default.addObserver(self, selector: #selector(getTodoItems), name: .updateTodoListView, object: nil)
        // Todoをロード
//        reloadData()
    }

}
private extension TodoListViewController {
    // MARK: - Actions
    @objc func tapedAddBotton(_ sender: Any) {
        
        Router.shared.showTodoAdd(from: self)
    }
    @objc func tapedLeftBarButton(_ sender: Any) {
        Router.shared.showSetting(from: self)
    }
    @objc func tapedReighBarButton(_ sender: Any) {
        getUncompletedTodos()
    }
    @objc func toggleTodoStatus() {
            showingDone.toggle()
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: showingDone ? "checkmark.circle" : "circle")
            reloadData()
        }
//    @objc func getTodoItems() {
//        print("通知を受け取った")
//        reloadData()
//    }

    // MARK: - Data Fetching
    func reloadData() {
        if showingDone {
            getAllTodos()
        } else {
            getUncompletedTodos()
        }
    }
    func getAllTodos() {
        FirebaseDBManager.getTodoDataForFirestore() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            case.success(let todos):
                self.todoItems = todos
                self.tableView.reloadData()
            }
        }
    }
    func getUncompletedTodos() {
        FirebaseDBManager.getUndoneTodoDataForFirestore() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            case.success(let todos):
                self.todoItems = todos
                self.tableView.reloadData()
            }
        }
    }

}


// MARK: - TableView
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var todoItem = todoItems[indexPath.row]
        todoItem.isDone.toggle()
        FirebaseDBManager.updateTodoData(todoItem: todoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                Alert.showErrorAlert(vc: self, error: error)
            case.success():
                self.todoItems[indexPath.row] = todoItem
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 削除スワイプ
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let itemToRemove = self.todoItems[indexPath.row]
            FirebaseDBManager.deleteTodoData(todoItem: self.todoItems[indexPath.row]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case.failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                case.success():
                    print("削除")
                    // itemToRemove.idと同じ要素をもつ最初のインデックスを探して削除
                    if let index = self.todoItems.firstIndex(where: { $0.id == itemToRemove.id }) {
                        self.todoItems.remove(at: index)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            completionHandler(true)
        }
        // Editスワイプ
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            completionHandler(true)
            Router.shared.showTodoEdit(from: self, todoItems: self.todoItems[indexPath.row])
        }
        editAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.className) as? TodoListCell else { fatalError() }
        let item = todoItems[indexPath.row]
        cell.configure(todoItem: item)
        return cell
    }

}

