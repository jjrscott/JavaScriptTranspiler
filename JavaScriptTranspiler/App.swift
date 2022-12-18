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
                let data = try JSONSerialization.data(withJSONObject: root)
                let program = try JSONDecoder().decode(AnyNode.self, from: data)
                
                swiftCode += program.swiftCode
            }
        }
        try swiftCode.write(toFile: output, atomically: true, encoding: .utf8)
    }
}
