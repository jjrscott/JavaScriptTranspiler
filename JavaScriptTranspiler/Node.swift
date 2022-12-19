//
//  Node.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

protocol Node: Decodable {
    func swiftCode(stack: NodeStack) throws -> String
}

extension Node {
    func swiftCode(stack: NodeStack) throws -> String {
        print("Unhandled node \(Self.self)")
        return "«\(Self.self)» /* \(self) */"
    }
}

extension Optional where Wrapped: Node {
    func swiftCode(stack: NodeStack, prefix: String = "", suffix: String = "", fallback: String = "") throws -> String {
        switch self {
        case .none:
            return fallback
        case .some(let wrapped):
            return try prefix + wrapped.swiftCode(stack: stack) + suffix
        }
    }
}

extension Array where Element: Node {
    func swiftCode(stack: NodeStack, prefix: String = "", separator: String = "", suffix: String = "", fallback: String = "") throws -> String {
        if count == 0 {
            return fallback
        } else {
            return try prefix + map({ try $0.swiftCode(stack: stack) }).joined(separator: separator) + suffix
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

enum NodeType {
    case type(String)
    case dict([String: NodeType])
}

struct NodeStack {
    var identifiers: [String]
    let types: [String: Any]
    
    func stack(with node: Node) -> NodeStack {
        if let identifier = node as? Identifier {
            return NodeStack(identifiers: identifiers + [identifier.name], types: types)
        } else if let node = node as? AnyNode {
            return stack(with: node.node)
        } else {
            return self
        }
    }
    
    func stack(with name: String) -> NodeStack {
        return NodeStack(identifiers: identifiers + [name], types: types)
    }
    
    var path: String { identifiers.joined(separator: ", ") }
    
    var swiftType: String? {
        swiftType(identifiers: identifiers, types: types)
    }
    
    func swiftType(identifiers: [String], types: [String: Any]) -> String? {
        if let identifier = identifiers.first,
        let value = types[identifier] {
            if let value = value as? String {
                return value
            } else if let value = value as? [String: Any] {
                return swiftType(identifiers: Array(identifiers.dropFirst(1)), types: value)
            } else {
                fatalError()
            }
        } else {
            return nil
        }
    }
}
