//
//  SettingViewController.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit

final class SettingViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: SettingCell.className, bundle: nil), forCellReuseIdentifier: SettingCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeNotifications()
    }
}
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップするセルによって画面遷移分岐
        switch indexPath.row {
            // アカウントアップグレード
        case SettingItemCell.AccountUpgrade.rawValue:
            DispatchQueue.main.async {
                if UserDefaults.standard.isAuthAccountCreated {
                    Alert.okAlert(vc: self, title: R.string.localizable.upgradeIsComplete(), message: "")
                    return
                }
                Alert.cancelAlert(vc: self, title: R.string.localizable.accountUpgrade(), message: R.string.localizable.yourDataWillBeTransferredAsIs(), handler: { [weak self] _ in
                    guard let self = self else { return }
                    Router.shared.showAccountUpgrade(from: self)
                })
            }
            // サインアウト
        case SettingItemCell.singOutCellRow.rawValue:
            DispatchQueue.main.async {
                Alert.cancelAlert(vc: self, title: R.string.localizable.signOut(), message: "",handler: { [weak self] _ in
                    FirebaseUserManager.singOut { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case.failure(let error):
                            Alert.showErrorAlert(vc: self, error: error)
                        case.success():
                            UserDefaults.standard.isLogined = false
                            UserDefaults.standard.isAuthAccountCreated = false
                            Router.shared.showReStart()
                        }
                    }
                })
            }
            // アカウント削除
        case SettingItemCell.withDrawCellRow.rawValue:
            //TODO: メインスレッドで実行
            Alert.cancelAlert(vc: self, title: R.string.localizable.areYouSureYouWantToDeleteYourAccount(), message: R.string.localizable.areYouSureYouWantToDeleteYourSavedInformation() ,handler: { [weak self] _ in
                FirebaseUserManager.withDarw { [weak self] result in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        switch result {
                        case.failure(let error):
                            Alert.showErrorAlert(vc: self, error: error)
                        case.success():
                            UserDefaults.standard.isLogined = false
                            UserDefaults.standard.isAuthAccountCreated = false
                            Router.shared.showReStart()
                        }
                    }
                }
            })
        default:
            Router.shared.showStettingItems(from: self, settingItem: settingItems[indexPath.row])
        }
    }

}
private extension SettingViewController {
    // MARK: - Notification Handling
    func observeNotifications() {
        NetworkMonitor.shared.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost), name: NetworkMonitor.connectionLost, object: nil)
    }
    @objc func connectionLost() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Alert.okAlert(vc: self, title: R.string.localizable.networkErrors(), message: NetworkMonitor.connectionLost.rawValue)
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
