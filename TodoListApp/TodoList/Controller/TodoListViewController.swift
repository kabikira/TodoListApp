//
//  TodoListViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class TodoListViewController: UIViewController {

    private var todoItems: [TodoItemModel] = []
    // 完了済みかの判定するのBool値
    private var showingDone = true
    // 最初はtodsFirstのデータを取得して表示
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
            image: UIImage(systemName: showingDone ? ImageNames.checkmarkCircle : ImageNames.circle),
                    style: .plain,
                    target: self,
                    action: #selector(toggleTodoStatus)
                )
        navigationItem.title = R.string.localizable.todoList()
        // 設定画面に遷移
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: ImageNames.gearshape), style: .done, target: self, action: #selector(tapedLeftBarButton(_:)))
    }

}
private extension TodoListViewController {
    // MARK: - ButtonActions
    @objc func tapedAddBotton(_ sender: Any) {
        // リスト追加画面に遷移
        Router.shared.showTodoAdd(from: self, todos: selectedTodos)
    }
    @objc func tapedLeftBarButton(_ sender: Any) {
        // 設定画面に遷移
        Router.shared.showSetting(from: self)
    }
    @objc func toggleTodoStatus() {
        // 完了､未完了を切り替え
        showingDone.toggle()
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: showingDone ? ImageNames.checkmarkCircle : ImageNames.circle)
        // todo
        reloadData()
    }
    // セグメントをタップして切り替えしtodosの各項目を取得
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
    // 完了済み､未完了済みを一緒に表示 or 未完了のみのリストを表示する
    func reloadData() {
        startIndicator()
        if showingDone {
            getAllTodos()
        } else {
            getUncompletedTodos()
        }
    }
    // すべてのリストを取得
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
    // 未完了のリストを取得
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
    // ネットワーク接続状態を監視
    func observeNotifications() {
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NetworkMonitor.connectionLost, object: nil)
    }
    // ネット接続が切れたらアラート表示
    @objc func connectionLost() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Alert.okAlert(vc: self, title: R.string.localizable.networkErrors(), message: NetworkMonitor.connectionLost.rawValue)
        }
    }
}


// MARK: - TableView
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cellをタップしたときにアニメーション
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2,
                       animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                cell?.transform = CGAffineTransform.identity
            }
        })
        // タップしたセルのに完了､未完了のチェックを切り替える
        tableView.deselectRow(at: indexPath, animated: true)
        var todoItem = todoItems[indexPath.row]
        todoItem.isDone.toggle()
        // todosデータを更新
        FirebaseDBManager.updateTodoData(todos: self.selectedTodos,todoItem: todoItem) { [weak self] result in
            DispatchQueue.main.async {
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
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 削除スワイプ
        let deleteAction = UIContextualAction(style: .destructive, title: R.string.localizable.delete()) { (action, view, completionHandler) in
            let itemToRemove = self.todoItems[indexPath.row]
            FirebaseDBManager.deleteTodoData(todos: self.selectedTodos,todoItem: self.todoItems[indexPath.row]) { [weak self] result in
                DispatchQueue.main.async {

                    guard let self = self else { return }
                    switch result {
                    case.failure(let error):
                        Alert.showErrorAlert(vc: self, error: error)
                    case.success():
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
        let editAction = UIContextualAction(style: .normal, title: R.string.localizable.edit()) { (action, view, completionHandler) in
            completionHandler(true)
            Router.shared.showTodoEdit(from: self, todoItems: self.todoItems[indexPath.row], todos: self.selectedTodos)
        }
        editAction.backgroundColor = .systemGreen
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

