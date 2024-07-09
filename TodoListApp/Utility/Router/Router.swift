//
//  Router.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import UIKit

protocol RouterProtocol {
    func showRoot(window: UIWindow?)
    func showLogin(from: UIViewController)
    func showNewRegistration(from: UIViewController)
    func showAccountUpgrade(from: UIViewController)
    func showEmailUpdate(from: UIViewController, isNewRegistration: Bool)
    func showPasswordReset(from: UIViewController)
    func showTodoList(from: UIViewController)
    func showTodoAdd(from: UIViewController, todos: String)
    func showTodoEdit(from: UIViewController, todoItems: TodoItemModel, todos: String)
    func showSetting(from: UIViewController)
    func showStettingItems(from: UIViewController, settingItem: SettingItem)
    func replaceRootWithTodoList()
    func showReStart()
}

final class Router: RouterProtocol {
    static let shared: Router = .init()
    private init() {}

    private var window: UIWindow?
    func showRoot(window: UIWindow?) {
        // UserDegaultsの値で起動経路を切り替える
        if UserDefaults.standard.isLogined {
            guard let vc = R.storyboard.todoList.instantiateInitialViewController() else { return }
            let nav = UINavigationController(rootViewController: vc)
            window?.rootViewController = nav
        } else {
            guard let vc = R.storyboard.login.instantiateInitialViewController() else { return }
            vc.inject()
            let nav = UINavigationController(rootViewController: vc)
            window?.rootViewController = nav
        }
        window?.makeKeyAndVisible()
        self.window = window
    }
    func showLogin(from: UIViewController) {
        guard let login = R.storyboard.login.instantiateInitialViewController() else { return }
        show(from: from, to: login)
    }

    func showNewRegistration(from: UIViewController) {
        guard let newRegistration = R.storyboard.newRegistration.instantiateInitialViewController() else { return }
        show(from: from, to: newRegistration)
    }
    func showAccountUpgrade(from: UIViewController) {
        guard let accountUpgrade = R.storyboard.accountUpgrade.instantiateInitialViewController() else { return }
        showPresent(from: from, to: accountUpgrade)
        
    }
    func showEmailUpdate(from: UIViewController, isNewRegistration: Bool = false) {
        guard let emailUpdate = R.storyboard.emailUpdate.instantiateInitialViewController() else { return }
        emailUpdate.setAsNewRegistration(isNewRegistration: isNewRegistration)
        showPresent(from: from, to: emailUpdate)
    }

    func showPasswordReset(from: UIViewController) {
        guard let passwordReset = R.storyboard.passwordReset.instantiateInitialViewController() else { return }
        showPresent(from: from, to: passwordReset)
    }

    func showTodoList(from: UIViewController) {
        guard let todoList = R.storyboard.todoList.instantiateInitialViewController() else { return }
        show(from: from, to: todoList)
    }

    func showTodoAdd(from: UIViewController, todos: String = FirebaseCollections.Todos.todosFirst.rawValue) {
        guard let todoAdd = R.storyboard.todoAdd.instantiateInitialViewController() else { return }
        todoAdd.configure(todos: todos)

        show(from: from, to: todoAdd)
    }
    func showTodoEdit(from: UIViewController, todoItems: TodoItemModel, todos: String = FirebaseCollections.Todos.todosFirst.rawValue) {
        guard let todoEdit = R.storyboard.todoEdit.instantiateInitialViewController() else { return }
        todoEdit.configure(todoItems: todoItems, todos: todos)

        show(from: from, to: todoEdit)
    }
    func showSetting(from: UIViewController) {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "SettingViewController") { coder in
            return SettingViewController(coder: coder, firebaseUserManager: FirebaseUserManager())
        }
        show(from: from, to: controller)
    }
    func showStettingItems(from: UIViewController, settingItem: SettingItem) {
        // お問い合わせとプライバシーアンドポリシーはブラウザから見てもらう
        switch settingItem.title {
        case settingItems[1].title:
            guard let url = URL(string: URLs.googleForms) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case settingItems[2].title:
            guard let url = URL(string: URLs.privacyPolicy) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }

        default:
            break
        }
    }
    // EmailUpdateからTodoListへ画面遷移させる
    func replaceRootWithTodoList() {
        guard let todoList = R.storyboard.todoList.instantiateInitialViewController() else { return }
        let nav = UINavigationController(rootViewController: todoList)
        window?.rootViewController = nav
    }
    func showReStart() {
        showRoot(window: window)
    }
    private func show(from: UIViewController, to: UIViewController, completion:(() -> Void)? = nil) {
        if let nav = from.navigationController {
            nav.pushViewController(to, animated: true)
            completion?()
        } else {
            from.present(to, animated: true, completion: completion)
        }
    }
    private func showPresent(from: UIViewController,to: UIViewController) {
        from.present(to , animated: true)
    }
}
