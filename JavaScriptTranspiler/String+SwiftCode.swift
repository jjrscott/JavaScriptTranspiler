//
//  String+SwiftCode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 19/12/2022.
//

import Foundation

extension String {
    func swiftQuoteWrap() -> String {


        if contains("\n") {
            return "\"\"\"\n\(self)\n\"\"\""
        } else {
            return "\"\(self)\""
        }
    }
    
    func swiftQuoteEscape() -> String {
        var contents = self
        for token in ["\\", "\""] {
            contents = contents.replacingOccurrences(of: token, with: "\\"+token)
        }
        return contents
    }
    
    
    
}

extension Optional where Wrapped == String {
    func swiftCode(prefix: String = "", suffix: String = "", fallback: String = "") -> String {
        switch self {
        case .none:
            return fallback
        case .some(let wrapped):
            return prefix + wrapped + suffix
        }
    }
}
