//
//  FirebaseTodoManager.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import Firebase

// MARK: - Todoリスト作成
final class FirebaseDBManager {
   static func createTodo(title: String, notes: String, completion: @escaping(Result<Void, NSError>) -> Void) {
        if let user = Auth.auth().currentUser {
            let createdTime = FieldValue.serverTimestamp()
            Firestore.firestore().collection("user").document(user.uid).collection("todosFirst").document().setData(
                [
                    "title": title,
                    "notes": notes,
                    "isDone": false,
                    "createdAt": createdTime,
                    "updatedAt": createdTime
                ],merge: true
                ,completion: { error in
                    if let error = error {
                        completion(.failure(error as NSError))
                    } else {
                        completion(.success)
                    }
                }
            )
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "User not logged in"])
            completion(.failure(error))
        }

    }
    // MARK: - 全Todoデータを取得
    static func getTodoDataForFirestore(completion: @escaping(Result<[TodoItemModel], Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            print("Current User ID: \(user.uid)") // ユーザーIDをログに出力します
            Firestore.firestore().collection("user").document(user.uid).collection("todosFirst").order(by: "createdAt").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error: \(error)") // エラーをログに出力します
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    print("Query Snapshot: \(querySnapshot)") // querySnapshotをログに出力します
                    var todos = [TodoItemModel]()
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        guard
                            let title = data["title"] as? String,
                            let notes = data["notes"] as? String,
                            let isDone = data["isDone"] as? Bool
                        else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data conversion error"])))
                            return
                        }
                        let todo = TodoItemModel(id: doc.documentID, title: title, notes: notes, isDone: isDone)
                        todos.append(todo)
                    }
                    print("Todos: \(todos)") // todosをログに出力します
                    completion(.success(todos))
                }
            }
        } else {
            print("No user logged in.") // ユーザーがログインしていない場合のメッセージをログに出力します
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
        }
    }
    // MARK: - 未完了のTodoを取得
    static func getUndoneTodoDataForFirestore(completion: @escaping(Result<[TodoItemModel], Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("user").document(user.uid).collection("todosFirst").whereField("isDone", isEqualTo: false).order(by: "createdAt").getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    var todos = [TodoItemModel]()
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        guard
                            let title = data["title"] as? String,
                            let notes = data["notes"] as? String,
                            let isDone = data["isDone"] as? Bool
                        else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data conversion error"])))
                            return
                        }
                        let todo = TodoItemModel(id: doc.documentID, title: title, notes: notes, isDone: isDone)
                        todos.append(todo)
                    }
                    completion(.success(todos))

                }
            }
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
        }
    }

    // MARK: - 　Todoをアップデート
    static func updateTodoData(todoItem: TodoItemModel, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("user").document(user.uid).collection("todosFirst").document(todoItem.id).updateData(
                [
                    "title": todoItem.title,
                    "notes": todoItem.notes,
                    "isDone": todoItem.isDone,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                ,completion:  { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        completion(.failure(error))
                    } else {
                        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        print(todoItem)
                        completion(.success)
                    }

                }
            )
        }
    }
    // MARK: - 　Todoを削除
    static func deleteTodoData(todoItem: TodoItemModel, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("user").document(user.uid).collection("todosFirst").document(todoItem.id).delete() { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        }
    }
}
