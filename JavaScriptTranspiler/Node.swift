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
    var swiftCode: String {
        print("Unhandled node \(Self.self)")
        return "«\(Self.self)» /* \(self) */"
    }
}

extension Optional where Wrapped: Node {
    func swiftCode(prefix: String = "", suffix: String = "", fallback: String = "") -> String {
        switch self {
        case .none:
            return fallback
        case .some(let wrapped):
            return prefix + wrapped.swiftCode + suffix
        }
    }
}

extension Array where Element: Node {
    func swiftCode(prefix: String = "", separator: String = "", suffix: String = "", fallback: String = "") -> String {
        if count == 0 {
            return fallback
        } else {
            return prefix + map(\.swiftCode).joined(separator: separator) + suffix
        }
    }
}

extension Node {
    func printType() {
        print(Self.self)
    }
}

extension AnyNode {
    func printType() {
        node.printType()
    }
}
