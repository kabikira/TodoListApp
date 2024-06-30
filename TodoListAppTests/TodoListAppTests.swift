//
//  TodoListAppTests.swift
//  TodoListAppTests
//
//  Created by koala panda on 2024/06/10.
//

import XCTest
import Quick
import Nimble
import RxTest
import RxBlocking
@testable import TodoListApp

// Routerをモック化する理由
//モック化する理由
//実行速度の向上:
//
//実際の画面遷移を行うと、UIの更新やアニメーションの終了を待つ必要があり、テストの実行速度が遅くなることがあります。モック化することで、これらの待ち時間を排除できます。
//テストの確実性:
//
//画面遷移が正しく行われたかどうかを確実に検証できます。例えば、実際の画面遷移では、遷移先の画面が正しく設定されているか、遷移アニメーションが完了しているかなど、テストが不安定になる要因が多く存在します。
//分離されたテスト:
//
//モックを使用することで、画面遷移のロジックと実際の画面の実装を分離してテストできます。これにより、画面遷移のロジックが正しく機能しているかどうかを独立して確認できます。

class MockRouter: RouterProtocol {

    var didShowPasswordReset = false

    func showStettingItems(from: UIViewController, settingItem: TodoListApp.SettingItem) {}
    func showReStart() {}
    func showRoot(window: UIWindow?) {}
    func showLogin(from: UIViewController) {}
    func showNewRegistration(from: UIViewController) {}
    func showAccountUpgrade(from: UIViewController) {}
    func showEmailUpdate(from: UIViewController, isNewRegistration: Bool) {}
    func showPasswordReset(from: UIViewController) {
        didShowPasswordReset = true
    }
    func showTodoList(from: UIViewController) {}
    func showTodoAdd(from: UIViewController, todos: String) {}
    func showTodoEdit(from: UIViewController, todoItems: TodoItemModel, todos: String) {}
    func showSetting(from: UIViewController) {}
    func replaceRootWithTodoList() {}
}

class LoginViewControllerTests: XCTestCase {

    func testPasswordResetButton() {
        let mockRouter = MockRouter()
        let viewModel = LoginViewModel()

        print("ストーリーボードから呼び出し")
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LoginViewController

//        guard let vc = R.storyboard.login.instantiateInitialViewController() else { return }
//        vc.inject(viewModel: viewModel, router: mockRouter)
        vc.viewModel = viewModel
        vc.router = mockRouter

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()

        vc.passwordResetButton.sendActions(for: .touchUpInside)

        // モーダル遷移をテスト
//        XCTAssertNotNil(vc.presentedViewController)
//        XCTAssertTrue(vc.presentedViewController is PasswordResetViewController)

        XCTAssertTrue(mockRouter.didShowPasswordReset)
    }
}
// パスワード忘れたボタン タップしてモダール表示
//

final class TodoListAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
