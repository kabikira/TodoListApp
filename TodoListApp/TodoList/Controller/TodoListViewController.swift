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
    private var selectedTodos = FirebaseCollections.Todos.todosFirst.rawValue


    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: TodoListCell.className, bundle: nil), forCellReuseIdentifier: TodoListCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var changeTodosControl: UISegmentedControl! {
        didSet {
            changeTodosControl.addTarget(self, action: #selector(tapedChangeTodosControl(_:)), for: .valueChanged)
        }
    }
    @IBOutlet private weak var addTaskButton: UIButton! {
        didSet {
            addTaskButton.addTarget(self, action: #selector(tapedAddBotton(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // ビューが表示されるときにデータをリロード
            reloadData()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        // ネットワーク接続を監視
        observeNotifications()
        // 完了済みを非表示にするボタン
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: UIImage(systemName: showingDone ? "checkmark.circle" : "circle"),
                    style: .plain,
                    target: self,
                    action: #selector(toggleTodoStatus)
                )
        navigationItem.title = "TodoList"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(tapedLeftBarButton(_:)))

    }

}
private extension TodoListViewController {
    // MARK: - Actions
    @objc func tapedAddBotton(_ sender: Any) {
        
        Router.shared.showTodoAdd(from: self, todos: selectedTodos)
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
    @objc func tapedChangeTodosControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedTodos = FirebaseCollections.Todos.todosFirst.rawValue
            reloadData()
        case 1:
            selectedTodos = FirebaseCollections.Todos.todosSecond.rawValue
            reloadData()
        case 2:
            selectedTodos = FirebaseCollections.Todos.todosThird.rawValue
            reloadData()
        case 3:
            selectedTodos = FirebaseCollections.Todos.todosFourth.rawValue
            reloadData()
        default:
            selectedTodos = FirebaseCollections.Todos.todosFirst.rawValue
        }
    }
    // MARK: - Indicator Control
    func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.indicator.isHidden = false
            self.indicator.startAnimating()
        }
    }

    func stopIndecator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
        }
    }

    // MARK: - Data Fetching
    func reloadData() {
        startIndicator()
        if showingDone {
            getAllTodos()
        } else {
            getUncompletedTodos()
        }
    }
    func getAllTodos() {
        FirebaseDBManager.getTodoDataForFirestore(todos: selectedTodos) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                case.success(let todos):
                    self.todoItems = todos
                    self.tableView.reloadData()
                }
                self.stopIndecator()
            }
        }

    }
    func getUncompletedTodos() {
        FirebaseDBManager.getUndoneTodoDataForFirestore(todos: selectedTodos) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.failure(let error):
                    Alert.showErrorAlert(vc: self, error: error)
                case.success(let todos):
                    self.todoItems = todos
                    self.tableView.reloadData()
                }
                self.stopIndecator()
            }
        }
    }
    // MARK: - Notification Handling
    func observeNotifications() {
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NetworkMonitor.connectionLost, object: nil)
    }
    @objc func connectionLost() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Alert.okAlert(vc: self, title: "Network Errors", message: NetworkMonitor.connectionLost.rawValue)
        }
    }
}


// MARK: - TableView
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var todoItem = todoItems[indexPath.row]
        todoItem.isDone.toggle()
        FirebaseDBManager.updateTodoData(todos: self.selectedTodos,todoItem: todoItem) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.failure(let error):
                DispatchQueue.main.async {
                    Alert.showErrorAlert(vc: self, error: error)
                }
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
            FirebaseDBManager.deleteTodoData(todos: self.selectedTodos,todoItem: self.todoItems[indexPath.row]) { [weak self] result in
                DispatchQueue.main.async {

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
            }
            completionHandler(true)
        }
        // Editスワイプ
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            completionHandler(true)
            Router.shared.showTodoEdit(from: self, todoItems: self.todoItems[indexPath.row], todos: self.selectedTodos)
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

