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
    // ASCIIの範囲外の文字を取り除く(全角文字を取り除く)
    func removingNonASCII() -> String {
            return self.replacingOccurrences(of: "[^\\x00-\\x7F]", with: "", options: .regularExpression)
        }
}
