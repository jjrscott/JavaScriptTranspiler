//
//  App.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 15/12/2022.
//

import Cocoa
import JavaScriptCore
import ArgumentParser

@main
struct Count: ParsableCommand {
    @Option var output: String
    @Argument var input: [String]

    mutating func run() throws {
        guard let context = JSContext() else { fatalError() }
        context.exceptionHandler = { (_, error) in
            print(error as Any, error?.objectForKeyedSubscript("message") as Any, error?.objectForKeyedSubscript("line") as Any)
            Darwin.exit(1)
        }
        
        let sourceCodeUrl = Bundle.main.url(forResource: "esprima", withExtension: "js")!
        let sourceCode = try String(contentsOf: sourceCodeUrl)
        context.evaluateScript(sourceCode, withSourceURL: sourceCodeUrl)
        
        var swiftCode = ""
        for path in input {
            swiftCode += "\n// MARK: - \(path)\n\n"
            let source = try String(contentsOfFile: path)
            
            if let result = context.objectForKeyedSubscript("esprima").objectForKeyedSubscript("parse").call(withArguments: [source])
                ,
               let root = result.toObject()
            {
                let data = try JSONSerialization.data(withJSONObject: root, options: .prettyPrinted)
                do {
                    let types: [String: Any] = [
                        "storagewrapper.js" : [
                            "storage_has": [
                                "return" : "Bool",
                                "key" : "String"],
                            "storage_get": [
                                "return" : "String?",
                                "key" : "String"],
                            "storage_set": [
                                "key" : "String",
                                "value" : "String"],
                            "storage_remove": [
                                "key" : "String"],
                    ]
                    ]
                    
                    
                    let stack = NodeStack(identifiers: [path], types: types)
                    let program = try JSONDecoder().decode(AnyNode.self, from: data)
                    swiftCode += try program.swiftCode(stack: stack)
                } catch let error as DecodingError {
                    switch error {
                    case .typeMismatch: //(let any, let context):
                        throw error
                    case .valueNotFound: //(let any, let context):
                        throw error
                    case .keyNotFound(let codingKey, let context):
                        print("Coding key \(codingKey) not found in \(value(root, for: context.codingPath.dropLast()))")
                    case .dataCorrupted: //(let context):
                        throw error
                    default:
                        throw error
                    }
                }
                
            }
        }
        try swiftCode.write(toFile: output, atomically: true, encoding: .utf8)
    }
    
    func value(_ value: Any?, for codingKeys: [CodingKey]) -> Any? {
        var value = value
        for key in codingKeys {
            if let object = value as? [String: Any?] {
                print("type: \(object["type"])")
                value = object[key.stringValue]
            } else if let array = value as? [Any?] {
                value = array[key.intValue!]
            } else {
                fatalError()
            }
            
            
        }
        return value
    }
}
