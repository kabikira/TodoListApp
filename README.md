# TodoListApp
Firebaseのログイン､データベースを使用したTodoアプリ  
<img width="150" src="https://github.com/user-attachments/assets/300cf866-61bf-4520-8c00-f5e68da5dd12">
<img width="150" src="https://github.com/user-attachments/assets/bf73a9b9-4b11-4790-8c8f-6779ee3f5bfb">
<img width="150" src="https://github.com/user-attachments/assets/bf8164b3-db3b-4f43-a364-2ac489527ede">
<img width="150" src="https://github.com/user-attachments/assets/12b6d9c0-4620-4a24-a298-c0be2717a84e">
<img width="150" src="https://github.com/user-attachments/assets/278bc3a5-afad-4a79-9989-308ecab2f191">


## 概要

* 設計 MVC  ログイン画面のみMVVM
* 画面遷移 Router  
* 外部ライブラリ  CocoaPodsで管理
    - Firebase
    - IQKeyboardManagerSwift
    - R.swift
    - LicensePlist
    - RxSwift
    - RxCocoa
## 作成理由
Firebaseのログイン機能や、NoSQLを使用して、基本的なCRUD操作を学習するため、  
自分のサービスを作ることが目的ではなく、iOSエンジニアとして最初に振られそうな細かいタスクに対応することをイメージして作成。  

## 自己評価
- 工夫した点:
	-  設計
		- Cocoa MVCで実装､ログイン画面のみRxSwiftを学習しMVVMでの実装に改修した。
		- Routerパターンを使用し画面遷移に関する責務の分割した｡
	- 外部ライブラリの活用
		- R.Swiftでのハードコーディング対策
		- IQKeyboardManagerSwiftを使ってキーボード操作の煩わしさを軽減
		- LicensePlistでライセンス管理を自動化
	- ログイン周り
		- 匿名ログインを実装し、メールアドレスを登録しなくてもアプリを利用可能した、あとからメールアドレスを登録することによって匿名ユーザーから本ユーザーへ昇格できるように実装
		- 初回登録時にFirebase Authのメール認証で確認メールをチェックしたかどうか判定してからログインできるように実装
                - メールアドレスを間違って入力してしまったときのケア､パスワードを忘れてしまったときのメールでの新規パスワード登録をケアできるよう実装
	- 入力制限
		- 多量の文字入力を防ぐためUITextField、UITextViewに文字制限を実装
		- パスワードやEmail入力の際、UITextFieldにスペースを入力させないよう実装
	- UITableView
		- prepareForReuseメソッドを使用してCellの再利用するように実装
		- UITableViewCellのAccessoryをタスク完了､未完了を判断するチェックマークに使用
	- その他
		- 日本語､英語の多言語化対応
  		- NetworkMonitorでネットワーク接続を感知し、機内モード、ネットワークに繋がってない時にアラート出すよう実装
		- ライト､ダークモードに対応
		- レイアウト変更に柔軟に対応できるようできるだけ､UIStackViewを使用した｡
		- UserDefaultsでアプリ起動時の画面を制御
		- Storyboard開く際のロード時間を短縮､編集､共同開発しやすいように1Storyboard, 1ViewControllerとした｡
		- issueを立てアプリの課題を可視化し､その課題に対してブランチを切って対応した｡

- 問題点:
	- テストコード実装
		- ブランチ https://github.com/kabikira/TodoListApp/tree/feature-Add-tests にてQuick､Nimbleを使用してテストを実装を試みたが以下の問題点があり実装に至らなかった｡
			-  FirebaseUserManager.swiftやRouter.swift､Alert.swift等がスタティックメソッドで呼び出していること､直接Firebaseに依存しているメソッドを使用していたため、ユニットテストの際にモックを使うことができない作りになっていた｡
			- ViewControllerで```private extension NewRegistrationViewController {}```のように､private extensionの中で関数を記述していたので､外部からアクセスできずテストを書きづらく実装してしまった｡
	
	- R.Swiftを使用したローカライズ
		- ```R.string.localizable.weCannotGuaranteeDataPermanenceIfYouWishToRetainTheDataInYourAccountWeRecommendThatYouRegisterForAFormalAccount())```のようにハードコートをさけて呼び出しているが文章をそのまま変数にしているため､冗長になってしまった｡
		
	- UIのデザインがシンプルすぎる

### アウトプット

- テスト関して知識が足りないことが多かったので､書籍､記事から学びサンプルアプリを作成｡Qiitaに記事としてまとめて投稿しました｡[Qiita記事リンク](https://qiita.com/Imael/items/75aac8aeff1a310261da) 
- 初めてFirebaseを利用するにあたって､ログイン機能のみのプロジェクトなど､小さいプロジェクトを何個か作り､動作を確認しながら作成していった｡その際の役だったリンク集をQiitaに記事を投稿しました｡[Qiita記事リンク](https://qiita.com/Imael/items/b733ac37c7239a42786b) 
