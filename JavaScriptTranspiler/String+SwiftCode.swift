//
//  String+SwiftCode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 19/12/2022.
//

import Foundation

extension String {
    var swiftCode: String {
        var contents = self
        for token in ["\\", "\""] {
            contents = contents.replacingOccurrences(of: token, with: "\\"+token)
        }
        
        if contents.contains("\n") {
            return "\"\"\"\(contents)\n\"\"\""
        } else {
            return "\"\(contents)\""
        }
    }
}
