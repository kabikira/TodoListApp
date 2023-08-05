//
//  SettingViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

class SettingViewController: UIViewController {


    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: SettingCell.className, bundle: nil), forCellReuseIdentifier: SettingCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: セルによって画面遷移分岐させる
        switch indexPath.row {
        case SettingItemCell.singOutCellRow.rawValue:
            Alert.cancelAlert(vc: self, title: "Sign out?", message: "",handler: { [weak self] _ in
                FirebaseUserManager.singOut { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case.failure(let error):
                        self.showErrorAlert(error: error, vc: self)
                    case.success():
                        print("サインアウト")
                        UserDefaults.standard.isLogined = false
                        Router.shared.showReStart()
                    }
                }
            })
        case SettingItemCell.withDrawCellRow.rawValue:
            Alert.cancelAlert(vc: self, title: "Are you sure you want to delete your account?", message: "Are you sure you want to delete your saved information?" ,handler: { [weak self] _ in
                FirebaseUserManager.withDarw { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case.failure(let error):
                        self.showErrorAlert(error: error, vc: self)
                    case.success():
                        print("退会成功")
                        UserDefaults.standard.isLogined = false
                        Router.shared.showReStart()
                    }
                }
            })
        default:
            Router.shared.showStettingItems(from: self, settingItem: settingItems[indexPath.row])
        }
    }

}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.className) as? SettingCell else {
            fatalError()
        }
        let settingItem = settingItems[indexPath.row]
        cell.configure(settingItem: settingItem)
        return cell
    }


}
