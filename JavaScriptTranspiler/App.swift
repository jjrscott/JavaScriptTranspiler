//
//  App.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 15/12/2022.
//

import Cocoa
import JavaScriptCore
import ArgumentParser
import SwiftFormat
import SwiftFormatConfiguration
import SwiftSyntax

@main
struct JavaScriptTranspiler: ParsableCommand {
    @Option var output: String
    @Option var ast: String?
    @Option var types: String?
    @Argument var input: [String]
    @Flag(inversion: .prefixedNo) var format = true

    mutating func run() throws {
        guard let context = JSContext() else { fatalError() }
        context.exceptionHandler = { (_, error) in
            print(error as Any, error?.objectForKeyedSubscript("message") as Any, error?.objectForKeyedSubscript("line") as Any)
            Darwin.exit(1)
        }
        
        let sourceCodeUrl = Bundle.main.url(forResource: "esprima", withExtension: "js")!
        let sourceCode = try String(contentsOf: sourceCodeUrl)
        context.evaluateScript(sourceCode, withSourceURL: sourceCodeUrl)
        
        let swiftTypes: [String: Any]
        if let types = types {
            swiftTypes = (try? JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: types))) as? [String: Any]) ?? [:]
        } else {
            swiftTypes = [:]
        }
        
        let nodeTypes = NodeTypes()
        
        var jsonAST = [String:Any]()
        
        var swiftCode = ""
        for path in input {
            swiftCode += "\n// MARK: - \(path)\n\n"
            let source = try String(contentsOfFile: path)
            
            if let result = context.objectForKeyedSubscript("esprima").objectForKeyedSubscript("parse").call(withArguments: [source])
                ,
               let root = result.toObject()
            {
                jsonAST[path] = root
                let data = try JSONSerialization.data(withJSONObject: root, options: .prettyPrinted)
                do {
                    let stack = NodeStack(identifiers: [path], types: swiftTypes, nodeTypes: nodeTypes)
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
            }
        }
        
        let outputUrl = URL(fileURLWithPath: output)
        
        if format {
            do {
                swiftCode = try prettify(text: swiftCode, assumingFileURL: outputUrl)
            } catch let error as SwiftFormatError {
                switch error {
                case .fileNotReadable:
                    print("Formatting failed with error \(error). Skipping")
                case .isDirectory:
                    print("Formatting failed with error \(error). Skipping")
                case .fileContainsInvalidSyntax(let position):
                    let location = SourceLocationConverter(file: outputUrl.path, source: swiftCode).location(for: position)
                    print("file contains invalid or unrecognized Swift syntax at \(location)")
                }
            }
        }
        
        if let ast {
            try JSONSerialization.data(withJSONObject: jsonAST, options: [.prettyPrinted, .sortedKeys]).write(to:
URL(fileURLWithPath: ast))
        }
        
        try swiftCode.write(to: outputUrl, atomically: true, encoding: .utf8)
        if let types = types {
            try JSONSerialization.data(withJSONObject: nodeTypes.data, options: [.prettyPrinted, .sortedKeys]).write(to:
URL(fileURLWithPath: types))
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
