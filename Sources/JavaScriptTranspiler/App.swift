//
//  App.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 15/12/2022.
//

import Foundation
import JavaScriptCore
import ArgumentParser
//import SwiftFormat
//import SwiftFormatConfiguration
//import SwiftSyntax

@main
struct JavaScriptTranspiler: ParsableCommand {
    @Option var input: String
    @Option var output: String
    @Option var types: String?
    @Option var ast: String?

    mutating func run() throws {
        guard let context = JSContext() else { fatalError() }
        context.exceptionHandler = { (_, error) in
            print(error as Any, error?.objectForKeyedSubscript("message") as Any, error?.objectForKeyedSubscript("line") as Any)
            Darwin.exit(1)
        }
        
        context.evaluateScript(esprimaSourceCode)
                
        print("error: \(input)")
        
        let swiftTypes: [String: Any]
        if let types = types {
            swiftTypes = (try? JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: types))) as? [String: Any]) ?? [:]
        } else {
            swiftTypes = [:]
        }
        
        let nodeTypes = NodeTypes()
        
        let inputUrl = URL(fileURLWithPath: input)
        let outputUrl = URL(fileURLWithPath: output)
        
        let typesUrl: URL?
        if let types {
            typesUrl = URL(fileURLWithPath: types)
        } else {
            typesUrl = nil
        }
        
        let astUrl: URL?
        if let ast {
            astUrl = URL(fileURLWithPath: ast)
        } else {
            astUrl = nil
        }
        

        var swiftCode = "// \(inputUrl.lastPathComponent)\n\n"
        let source = try String(contentsOf: inputUrl)
        
        guard let result = context.objectForKeyedSubscript("esprima").objectForKeyedSubscript("parse").call(withArguments: [source]) else {
            throw GenericError()
        }
        
        guard let root = result.toObject() else {
            throw GenericError()
        }
        
        if let astUrl {
            try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]).write(to: astUrl)
        }
        
        
        let data = try JSONSerialization.data(withJSONObject: root, options: .prettyPrinted)
        do {
            let stack = NodeStack(identifiers: [], types: swiftTypes, nodeTypes: nodeTypes)
            let program = try JSONDecoder().decode(AnyNode.self, from: data)
            swiftCode += try program.swiftCode(stack: stack)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch: //(let any, let context):
                throw error
            case .valueNotFound: //(let any, let context):
                throw error
            case .keyNotFound(let codingKey, let context):
                print("Coding key \(codingKey) not found in \(value(root, for: context.codingPath.dropLast()) ?? "nil")")
            case .dataCorrupted: //(let context):
                throw error
            default:
                throw error
            }
        }
                
        try swiftCode.write(to: outputUrl, atomically: true, encoding: .utf8)
        if let typesUrl {
            try JSONSerialization.data(withJSONObject: nodeTypes.data, options: [.prettyPrinted, .sortedKeys]).write(to:typesUrl)
        }
    }
    
    func value(_ value: Any?, for codingKeys: [CodingKey]) -> Any? {
        var value = value
        for key in codingKeys {
            if let object = value as? [String: Any?] {
//                print("type: \(object["type"])")
                value = object[key.stringValue] as Any?
            } else if let array = value as? [Any?] {
                value = array[key.intValue!]
            } else {
                fatalError()
            }
        }
        return value
    }
}
