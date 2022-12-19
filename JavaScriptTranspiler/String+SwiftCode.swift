//
//  String+SwiftCode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 19/12/2022.
//

import Foundation

extension String {
    func swiftCode(stack: NodeStack) throws -> String {
        var contents = self
        for token in ["\\", "\""] {
            contents = contents.replacingOccurrences(of: token, with: "\\"+token)
        }
        
        if contents.contains("\n") {
            return "\"\"\"\n\(contents)\n\"\"\""
        } else {
            return "\"\(contents)\""
        }
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
