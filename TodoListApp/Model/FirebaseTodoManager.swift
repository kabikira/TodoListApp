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
    static func createTodo(title: String, notes: String, todos: String = FirebaseCollections.Todos.todosFirst.rawValue, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let createdTime = FieldValue.serverTimestamp()
            Firestore.firestore().collection(FirebaseCollections.user).document(user.uid).collection(todos).document().setData(
                [
                    FirebaseFields.TodosItem.title.rawValue: title,
                    FirebaseFields.TodosItem.notes.rawValue: notes,
                    FirebaseFields.TodosItem.isDone.rawValue: false,
                    FirebaseFields.TodosItem.createdAt.rawValue: createdTime,
                    FirebaseFields.TodosItem.updatedAt.rawValue: createdTime
                ],merge: true
                ,completion: { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success)
                    }
                }
            )
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // MARK: - 全Todoデータを取得
    static func getTodoDataForFirestore(todos: String = FirebaseCollections.Todos.todosFirst.rawValue, completion: @escaping(Result<[TodoItemModel], Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection(FirebaseCollections.user).document(user.uid).collection(todos).order(by: FirebaseFields.TodosItem.createdAt.rawValue).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    var todos = [TodoItemModel]()
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        guard
                            let title = data[FirebaseFields.TodosItem.title.rawValue] as? String,
                            let notes = data[FirebaseFields.TodosItem.notes.rawValue] as? String,
                            let isDone = data[FirebaseFields.TodosItem.isDone.rawValue] as? Bool
                        else {
                            completion(.failure(ErrorHandling.TodoError.dataConversionError))
                            return
                        }
                        let todo = TodoItemModel(id: doc.documentID, title: title, notes: notes, isDone: isDone)
                        todos.append(todo)
                    }
                    completion(.success(todos))
                }
            }
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // MARK: - 未完了のTodoを取得
    static func getUndoneTodoDataForFirestore(todos: String = FirebaseCollections.Todos.todosFirst.rawValue, completion: @escaping(Result<[TodoItemModel], Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection(FirebaseCollections.user).document(user.uid).collection(todos).whereField(FirebaseFields.TodosItem.isDone.rawValue, isEqualTo: false).order(by: FirebaseFields.TodosItem.createdAt.rawValue).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    var todos = [TodoItemModel]()
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        guard
                            let title = data[FirebaseFields.TodosItem.title.rawValue] as? String,
                            let notes = data[FirebaseFields.TodosItem.notes.rawValue] as? String,
                            let isDone = data[FirebaseFields.TodosItem.isDone.rawValue] as? Bool
                        else {
                            completion(.failure(ErrorHandling.TodoError.dataConversionError))
                            return
                        }
                        let todo = TodoItemModel(id: doc.documentID, title: title, notes: notes, isDone: isDone)
                        todos.append(todo)
                    }
                    completion(.success(todos))
                }
            }
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // MARK: - 　Todoをアップデート
    static func updateTodoData(todos: String = FirebaseCollections.Todos.todosFirst.rawValue, todoItem: TodoItemModel, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection(FirebaseCollections.user).document(user.uid).collection(todos).document(todoItem.id).updateData(
                [
                    FirebaseFields.TodosItem.title.rawValue: todoItem.title,
                    FirebaseFields.TodosItem.notes.rawValue: todoItem.notes,
                    FirebaseFields.TodosItem.isDone.rawValue: todoItem.isDone,
                    FirebaseFields.TodosItem.updatedAt.rawValue: FieldValue.serverTimestamp()
                ]
                ,completion:  { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success)
                    }
                }
            )
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
    // MARK: - 　Todoを削除
    static func deleteTodoData(todos: String = FirebaseCollections.Todos.todosFirst.rawValue, todoItem: TodoItemModel, completion: @escaping(Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection(FirebaseCollections.user).document(user.uid).collection(todos).document(todoItem.id).delete() { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
        } else {
            completion(.failure(ErrorHandling.TodoError.userNotLoggedIn))
        }
    }
}
