//
//  NewRegistrationTests.swift
//  TodoListAppTests
//
//  Created by koala panda on 2024/07/10.
//

import XCTest
import RxSwift
import FirebaseAuth
@testable import TodoListApp

class MockUser {
    var uid: String
    var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }
}

class MockFirebaseUserManager: FirebaseUserManagerProtocol {
    
    var createUserResult: Result<Void, Error>?
    var registerUserNameResult: Result<Void, Error>?
    var anonymousLoginResult: Result<Void, Error>?
    var accountUpgradeResult: Result<Void, Error>?
    var updateEmailResult: Result<Void, Error>?
    var sendEmailVerificationResult: Result<Void, Error>?
    var checkAuthenticationEmailResult: Result<Void, Error>?
    var sendPasswordResetResult: Result<Void, Error>?
    var getCurrentUserResult: MockUser?
    var singOutResult: Result<Void, Error>?
    var withDarwResult: Result<Void, Error>?
    var rxSignInResult: Observable<Result<Void, Error>>?

    func anonymousLogin(completion: @escaping (Result<Void, Error>) -> Void) {

    }
    
    func accountUpgrade(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {

    }
    
    func updateEmail(to newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {

    }
    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {

    }
    func getCurrentUser() -> MockUser? {
        return MockUser(uid: "mockUID", email: "testuser@example.com")
    }

    func singOut(completion: @escaping (Result<Void, Error>) -> Void) {

    }
    
    func withDarw(completion: @escaping (Result<Void, Error>) -> Void) {

    }
    
    func rxSignIn(email: String, password: String) -> RxSwift.Observable<Result<Void, Error>> {
        return Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onNext(.failure(error))
                } else {
                    observer.onNext(.success(()))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    


    func createUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = createUserResult {
            completion(result)
        }
    }

    func registerUserName(userName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = registerUserNameResult {
            completion(result)
        }
    }

    func sendEmailVerification(to user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = sendEmailVerificationResult {
            completion(result)
        }
    }

    func checkAuthenticationEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = checkAuthenticationEmailResult {
            completion(result)
        }
    }
}

final class NewRegistrationTests: XCTestCase {
    var viewController: NewRegistrationViewController!
    var mockFirebaseUserManager: MockFirebaseUserManager!
    var storyboard: UIStoryboard!

    override func setUp() {
        super.setUp()
        storyboard = UIStoryboard(name: "NewRegistration", bundle: nil)
        mockFirebaseUserManager = MockFirebaseUserManager()
        viewController = storyboard.instantiateViewController(identifier: "NewRegistrationViewController") { coder in
            return NewRegistrationViewController(coder: coder, firebaseUserManager: self.mockFirebaseUserManager)
        }
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        mockFirebaseUserManager = nil
        storyboard = nil
        super.tearDown()
    }

    func testTappedSendMail_Success() {
        // Arrange
        mockFirebaseUserManager.createUserResult = .success(())
        mockFirebaseUserManager.registerUserNameResult = .success(())
        mockFirebaseUserManager.sendEmailVerificationResult = .success(())
        mockFirebaseUserManager.getCurrentUserResult = MockUser(uid: "mockUID", email: "testuser@example.com")
        viewController.registerEmailTextField.text = "test@example.com"
        viewController.registerPasswordTextField.text = "password"
        viewController.registerNameTextField.text = "username"

        // Act
        viewController.tappedSendMail(viewController.registerSendMailButton)

        // Assert
        XCTAssertFalse(viewController.wrongEmailButton.isHidden)
        // 他のアサーションも追加
    }

}
