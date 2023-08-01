//
//  UIViewController+.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import UIKit
import Firebase

//TODO: 後でローカライズに適応させる

extension UIViewController {
    func showErrorAlert(error: Error?, title: String = "エラーが起きました", vc: UIViewController) {
        guard let error = error else { return }
        print(title + error.localizedDescription)
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true, completion: nil)
    }
    // TODO: AlertMessageみたいな列挙型にまとめた文字列をわたしたほうがいいかな
    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        // エラー処理
        if let error = error as? AuthErrorCode {
            switch error.code {
            case .networkError: message = "ネットワークに接続できません"
            case .userNotFound: message = "ユーザが見つかりません"
            case .invalidEmail: message = "不正なメールアドレスです"
            case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
            case .wrongPassword: message = "入力した認証情報でサインインできません"
            case .userDisabled: message = "このアカウントは無効です"
            case .weakPassword: message = "パスワードが脆弱すぎます"
            default:
                print("unknown error")
            }
        }
        return message
    }

}
