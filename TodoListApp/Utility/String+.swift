//
//  String+.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/05.
//

import UIKit
// MARK: - String exetension
// 半角と全角のスペースを文字列から取り除くextension
extension String {
    func removingWhiteSpace() -> String {
        let whiteSpaces: CharacterSet = [" ", "　"]
        return self.trimmingCharacters(in: whiteSpaces)
    }
}
