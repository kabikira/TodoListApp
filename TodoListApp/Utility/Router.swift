//
//  Router.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import UIKit


final class Router {
    static let shared: Router = .init()
    private init() {}


    private var window: UIWindow?
    func showRoot(window: UIWindow?) {
        if UserDefaults.standard.isLogined {
                guard let vc = UIStoryboard.init(name: "TodoList", bundle: nil).instantiateInitialViewController() else {
                    return
                }
                let nav = UINavigationController(rootViewController: vc)
                window?.rootViewController = nav
            } else {
                guard let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateInitialViewController() else {
                    return
                }
                let nav = UINavigationController(rootViewController: vc)
                window?.rootViewController = nav
            }
        window?.makeKeyAndVisible()
        self.window = window
        }
    func showLogin(form: UIViewController) {
        guard let login = UIStoryboard.init(name: "Login", bundle: nil).instantiateInitialViewController() else {
            return
        }
        show(from: form, to: login)
    }

    func showNewRegistration(form: UIViewController) {
        guard let newRegistration = UIStoryboard.init(name: "NewRegistration", bundle: nil).instantiateInitialViewController() else { return }
        show(from: form, to: newRegistration)
    }

    func showPasswordReset(form: UIViewController) {
        guard let passwordReset = UIStoryboard.init(name: "PasswordReset", bundle: nil).instantiateInitialViewController() else { return }
        showPresent(from: form, to: passwordReset)
    }

    func showTodoList(from: UIViewController) {
        guard let todoList = UIStoryboard.init(name: "TodoList", bundle: nil).instantiateInitialViewController() else {
            return
        }
        show(from: from, to: todoList)
    }

    func showTodoAdd(from: UIViewController) {
        guard let todoAdd = UIStoryboard.init(name: "TodoAdd", bundle: nil).instantiateInitialViewController() else {
            return
        }

        show(from: from, to: todoAdd)
    }
    func showTodoEdit(from: UIViewController, todoItems: TodoItemModel) {
        guard let todoEdit = UIStoryboard.init(name: "TodoEdit", bundle: nil).instantiateInitialViewController() as? TodoEditViewController else {
            return
        }
        todoEdit.configure(todoItems: todoItems)

        show(from: from, to: todoEdit)
    }
    func showSetting(from: UIViewController) {
        guard let setting = UIStoryboard.init(name: "Setting", bundle: nil).instantiateInitialViewController() else {
            return
        }
        show(from: from, to: setting)
    }
    func showStettingItems(from: UIViewController, settingItem: SettingItem) {
        // お問い合わせとプライバシーアンドポリシーはブラウザから見てもらう
        switch settingItem.title {
        case settingItems[0].title:
            // TODO: チュートリアル画面を実装
            print("説明画面へ")
        case settingItems[1].title:
            print("お問い合わせ")
            guard let url = URL(string: URLs.googleForms) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case settingItems[2].title:
            print("プライバシ")
            guard let url = URL(string: URLs.privacyPolicy) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }

        default:
            break

        }
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
