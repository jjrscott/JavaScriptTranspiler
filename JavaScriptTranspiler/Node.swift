//
//  Node.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

protocol Node: Decodable {
    var swiftCode: String { get }
}

extension Node {
    var swiftCode: String { "«\(Self.self)»" }
}

extension Optional where Wrapped: Node {
    func swiftCode(prefix: String = "", suffix: String = "") -> String {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return prefix + wrapped.swiftCode + suffix
        }
    }
}
