//
//  String+.swift
//  TodoListApp
//
//  Created by koala panda on 2023/08/05.
//

import UIKit
// MARK: - String exetension

extension String {
    // 半角と全角のスペースを文字列から取り除く
    func removingWhiteSpace() -> String {
        let whiteSpaces: CharacterSet = [" ", "　"]
        return self.trimmingCharacters(in: whiteSpaces)
    }
}
