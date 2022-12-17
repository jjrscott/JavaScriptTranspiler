//
//  App.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 15/12/2022.
//

import Cocoa
import JavaScriptCore

@main
class MyApp {
    static func main() throws {
        guard let context = JSContext() else { fatalError() }
        context.exceptionHandler = { (_, error) in
            print(error, error?.objectForKeyedSubscript("message"), error?.objectForKeyedSubscript("line"))
        }
        
        let bridge: @convention(block) (String, [Any]) -> Any? = { action, arguments in
            switch action {
            case "print":
                print(arguments)
                return nil
            default: fatalError()
            }
            
        }
        context.setObject(bridge, forKeyedSubscript: "bridge" as NSString)

        
        let discountedPrice: @convention(block) (JSValue, JSValue) -> Float = { price, discount in
            return 0
        }
        context.setObject(object: discountedPrice, withName: "discountedPrice")
        
        
        context.evaluateScript("function print() { bridge('print', arguments) }")

        let sourceCodeUrl = Bundle.main.url(forResource: "esprima", withExtension: "js")!
        let sourceCode = try! String(contentsOf: sourceCodeUrl)
        let foo = context.evaluateScript(sourceCode, withSourceURL: sourceCodeUrl)
        
//        print(context.objectForKeyedSubscript("esprima").toObject())

        
//        print(context.objectForKeyedSubscript("esprima").toObject())
        
        if let result = context.objectForKeyedSubscript("esprima").objectForKeyedSubscript("parse").call(withArguments: [source, NSDictionary()])
            ,
           let root = result.toObject()
        {
            let data = try JSONSerialization.data(withJSONObject: root)
            let program = try JSONDecoder().decode(AnyNode.self, from: data)
            print(program)
            print(program.swiftCode)
        }
    }
    
    static func visit(node: Any?, stack: [(type: String, key: String)] = []) {
        if let object = node as? [String: Any] {
            guard let type = object["type"] as? String else {
                fatalError()
                
            }
            
            for (key, value) in object {
                if key == "type" { continue }
                visit(node: value, stack: stack + [(type: type, key: key)])
            }
//
//            switch type {
//            case "Program": visit(node: object["body"], stack: stack + [type])
//            case "Identifier": visit(node: object["name"], stack: stack + [type])
//            case "BlockStatement": visit(node: object["body"], stack: stack + [type])
//            case "FunctionDeclaration": visit(node: object["body"], stack: stack + [type])
//            default: fatalError(object.description)
//            }
        } else if let array = node as? [Any] {
            for subnode in array {
                visit(node: subnode, stack: stack)
            }
        } else {
            print("\(stack) = \(String(describing: node))")
        }
    }
        
    static let source = #"""

function storage_has(key){
    return localStorage.getItem(key)!==null;
}

function storage_get(key){
    return localStorage.getItem(key);
}

function storage_set(key,value){
    return localStorage.setItem(key,value);
}

function storage_remove(key){
    localStorage.removeItem(key);
}


"""#
}

class ExportsImpl: NSObject, JSExport {
    
    
}

extension JSContext {
    func setObject(object: Any, withName:String) {
        setObject(object, forKeyedSubscript: withName as NSCopying & NSObjectProtocol)
    }
}

extension JSValue {
    func setObject(object: Any, withName:String) {
        setObject(object, forKeyedSubscript: withName as NSCopying & NSObjectProtocol)
    }
}

struct Program: Node {
    var sourceType: String
    var body: [AnyNode]
    
    var swiftCode: String {
        body
            .map { $0.swiftCode + "\n" }
            .joined()
    }
}

struct VariableDeclaration: Node {
    var declarations: [AnyNode]
    var kind: String
    
    var swiftCode: String {
        declarations
            .map { kind + " " + $0.swiftCode + "\n" }
            .joined()
    }
}

struct VariableDeclarator: Node {
    var id: AnyNode
    var `init`: (AnyNode)?

    var swiftCode: String {
        if let `init` {
            return id.swiftCode + " = " + `init`.swiftCode
        } else {
            return id.swiftCode
        }
    }
}

struct Identifier: Node {
    var name: String

    var swiftCode: String {
        name
    }
}

struct Literal: Node {
    var value: RawDecodable?
    var raw: String
    
    var swiftCode: String {
        if raw == "null" {
            return "nil"
        } else {
            return raw
        }
    }
}

struct ExpressionStatement: Node {
    var expression: AnyNode
    var directive: String?

    
    var swiftCode: String {
        expression.swiftCode
    }
}

struct BinaryExpression: Node {
    var `operator`: String
    var left: AnyNode
    var right: AnyNode
    
    var swiftCode: String {
        let op: String
        switch `operator` {
//        case "instanceof":
//        case "in":
//        case "+":
//        case "-":
//        case "*":
//        case "/":
//        case "%":
//        case "**":
//        case "|":
//        case "^":
//        case "&":
//        case "==":
//        case "!=":
//        case "===":
        case "!==": op = "!="
//        case "<":
//        case ">":
//        case "<=":
//        case "<<":
//        case ">>":
//        case ">>>":
        default: op = `operator`
        }
        
        
        return left.swiftCode + " " + op + " " + right.swiftCode
    }
}

struct BlockStatement: Node {
    var body: [AnyNode]
    
    var swiftCode: String {
        body.map(\.swiftCode).joined(separator: "\n")
    }
}

struct FunctionDeclaration: Node {
    var id: Identifier?
    var params: [AnyNode]
    var body: BlockStatement
    var generator: Bool
    var async: Bool
    
    var swiftCode: String {
        if let id {
            let paramsSwiftCode = params.map {
                "_ "+$0.swiftCode + ": \(id.swiftCode.capitalized)\($0.swiftCode.capitalized)"
            }.joined(separator: ", ")
            
            return "func " + id.swiftCode + "("+paramsSwiftCode+") -> \(id.swiftCode.capitalized) {\n" + body.swiftCode + "\n}"
        } else {
            fatalError()
        }
    }
}

struct ReturnStatement: Node {
    var argument: (AnyNode)?
    
    var swiftCode: String {
        if let argument {
            return "return "+argument.swiftCode
        } else {
            return "return"
        }
    }
}

struct MemberExpression: Node {
    var computed: Bool
    var object: AnyNode
    var property: AnyNode

    var swiftCode: String {
        object.swiftCode + "." + property.swiftCode
    }
}

struct CallExpression: Node {
    var callee: AnyNode
    var arguments: [AnyNode]
    
    var swiftCode: String {
        callee.swiftCode + "(" + arguments.map(\.swiftCode).joined(separator: ", ") + ")"
    }
}

struct ObjectExpression: Node {
    var properties: [Property]
    
    var swiftCode: String {
        properties.map(\.swiftCode).joined(separator: "\n")
    }
    
}

struct Property: Node {
    var key: AnyNode
    var computed: Bool
    var value: (AnyNode)?
    var kind: String
    var shorthand: Bool
    
    var swiftCode: String {
        key.swiftCode + " : *** " + value!.swiftCode
    }
}

struct TemplateLiteral: Node {
    var quasis: [TemplateElement]
    var expressions: [AnyNode]
    
    var swiftCode: String {
        "TemplateLiteral«" + quasis.map(\.swiftCode).joined(separator: "•") + "»"
    }
}

struct TemplateElement: Node {
    var value: TemplateElementValue
    var tail: Bool;
    
    var swiftCode: String {
        "TemplateElement«\(value.swiftCode)•\(tail)»"
    }
}

struct TemplateElementValue: Node {
    var cooked: String
    var raw: String
    
    var swiftCode: String {
        "TemplateElementValue«" + cooked + "•" + raw + "»"
    }
}

protocol RuntimeDecoder {
    static func decode<T>(from decoder: Decoder) throws -> T
}

@propertyWrapper
struct RuntimeDecodable<R: RuntimeDecoder, V>: Decodable {
    var wrappedValue: V {
        get {
            _wrappedValue!
        }
        set {
            _wrappedValue = newValue
        }
    }
    
    var _wrappedValue: V?
    
    init(_ runtimeDecoder: R.Type) {
        
    }
    
    init(from decoder: Decoder) throws {
        self = try R.decode(from: decoder)
    }
}

struct NodeDecoder: RuntimeDecoder {
    static func decode<T>(from decoder: Decoder) throws -> T {
        fatalError()
    }
}


protocol Node: Decodable {
    var swiftCode: String { get }
}

struct AnyNode: Node {
    let node: any Node
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let nodeType = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        let swiftTypes: [any Node.Type] = [
            BinaryExpression.self,
            BlockStatement.self,
            CallExpression.self,
            ExpressionStatement.self,
            FunctionDeclaration.self,
            Identifier.self,
            Literal.self,
            MemberExpression.self,
            ObjectExpression.self,
            Program.self,
            Property.self,
            ReturnStatement.self,
            TemplateLiteral.self,
            //                TemplateElement.self,
            VariableDeclaration.self,
            VariableDeclarator.self,
        ]
        
        guard let swiftType = swiftTypes.first(where: { "\($0)" == nodeType }) else {
            fatalError("Unknown type: \(nodeType)")
        }
        
        node = try swiftType.init(from: decoder)
    }
    
    var swiftCode: String { node.swiftCode }
}
