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

## 自己評価
- 良い点:
	-  設計
		- Cocoa MVCで実装､ログイン画面のみRxSwiftを学習しMVVMでの実装に挑戦した｡
		- Routerを使用により画面遷移に関する責務の分割した｡
	- 外部ライブラリの活用
		- R.Swiftでのハードコーディング対策
		- IQKeyboardManagerSwiftを使ってキーボード操作の煩わしさを軽減
		- LicensePlistでライセンス管理を自動化
	- その他
		- 日本語､英語の多言語化対応
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

### アウトプット

- テスト関して知識が足りないことが多かったので､書籍､記事から学びサンプルアプリを作成｡Qiitaに記事としてまとめて投稿しました｡[Qiita記事リンク](https://qiita.com/Imael/items/75aac8aeff1a310261da) 
- 初めてFirebaseを利用するにあたって､ログイン機能のみのプロジェクトなど､小さいプロジェクトを何個か作り､動作を確認しながら作成していった｡その際のお世話になったリンク集をQiitaに記事を投稿しました｡[Qiita記事リンク](https://qiita.com/Imael/items/b733ac37c7239a42786b) 
