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

class NodeTypes {
    var data: [String: Any] = [:]
    
    func add(type: String?, for identifiers: [String]) {
//        print("\(identifiers.joined(separator: "/")) = \(type)")
        add(type: type, to: &data, for: identifiers)
    }
    
    private func add(type: String?, to: inout [String: Any], for identifiers: [String]) {
        guard let identifier = identifiers.first else { return }
        if identifiers.count > 1 {
            if var value = to[identifier] as? [String: Any] {
                add(type: type, to: &value, for: Array(identifiers.dropFirst()))
                to[identifier] = value
            } else {
                if let value = to[identifier], !(value is NSNull) {
                    fatalError("\(identifier) \(value)")
                }
                var value = [String: Any]()
                add(type: type, to: &value, for: Array(identifiers.dropFirst()))
//                print("Set \(identifier) (\(Array(identifiers.dropFirst()).joined(separator: "/")))")
                to[identifier] = value
            }
        } else if to[identifier] == nil {
            to[identifier] = type ?? NSNull()
        }
    }
}

struct NodeStack {
    var identifiers: [String]
    let types: [String: Any]
    let nodeTypes: NodeTypes
    
    func stack(with node: Node) -> NodeStack {
        if let identifier = node as? Identifier {
            return NodeStack(identifiers: identifiers + [identifier.name], types: types, nodeTypes: nodeTypes)
        } else if let node = node as? AnyNode {
            return stack(with: node.node)
        } else {
            return self
        }
    }
    
    func stack(with name: String) -> NodeStack {
        return NodeStack(identifiers: identifiers + [name], types: types, nodeTypes: nodeTypes)
    }
    
    var path: String { identifiers.joined(separator: ", ") }
    
    var swiftType: String? {
        let type = swiftType(identifiers: identifiers, types: types)
        nodeTypes.add(type: type, for: identifiers)
        return type
    }
    
    private func swiftType(identifiers: [String], types: [String: Any]) -> String? {
        if let identifier = identifiers.first,
        let value = types[identifier] {
            if let value = value as? String {
                return value
            } else if let value = value as? [String: Any] {
                return swiftType(identifiers: Array(identifiers.dropFirst(1)), types: value)
            } else if value is NSNull {
                return nil
            } else if let value = value as? Bool {
                return "\(value)"
            } else {
                fatalError()
            }
        } else {
            return nil
        }
    }
}
