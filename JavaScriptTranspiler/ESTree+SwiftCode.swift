//
//  ESTree+SwiftCode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

extension Program {
    var swiftCode: String {
        body
            .map { $0.swiftCode + "\n" }
            .joined()
    }
}

extension VariableDeclaration {
    var swiftCode: String {
        declarations
            .map { kind.swiftCode + " " + $0.swiftCode }
            .joined(separator: "\n")
    }
}

extension VariableDeclarationKind {
    var swiftCode: String {
        switch self {
        case .var: return "var"
        case .const:  return "let"
        case .let:  return "var"
        }
    }
}


extension VariableDeclarator {
    var swiftCode: String {
        if let `init` {
            return id.swiftCode + " = " + `init`.swiftCode
        } else {
            return id.swiftCode
        }
    }
}

extension Identifier {
    var swiftCode: String {
        name
    }
}

extension Literal {
    var swiftCode: String {
        switch value {
        case .string(value: let value): return value.swiftCode
        case .nil: return "nil"
        default: return raw
        }
    }
}

extension ExpressionStatement {
    var swiftCode: String {
        expression.swiftCode
    }
}

extension BinaryExpression {
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
        case "===": op = "=="
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

extension BlockStatement {
    var swiftCode: String { swiftCode(params: []) }
    
    func swiftCode(params: [FunctionParameter]) -> String {
        "{" + params.swiftCode(separator: ", ", suffix: " in") + "\n" + body.map(\.swiftCode).joined(separator: "\n").split(separator: "\n").map({"\t" + $0}).joined(separator: "\n") + "\n}"
    }
}

extension FunctionDeclaration {
    var swiftCode: String {
        if let id {
            let paramsSwiftCode = params.map {
                "_ "+$0.swiftCode + ": \(id.swiftCode.capitalized)\($0.swiftCode.capitalized)"
            }.joined(separator: ", ")

            return "func " + id.swiftCode + "("+paramsSwiftCode+") -> \(id.swiftCode.capitalized) " + body.swiftCode
        } else {
            fatalError()
        }
    }
}

extension ReturnStatement {
    var swiftCode: String {
        if let argument {
            return "return "+argument.swiftCode
        } else {
            return "return"
        }
    }
}

extension MemberExpression {
    var swiftCode: String {
        if computed {
            return object.swiftCode + "[" + property.swiftCode + "]"
        } else {
            return object.swiftCode + "." + property.swiftCode
        }
    }
}

extension CallExpression {
    var swiftCode: String {
        callee.swiftCode + "(" + arguments.map(\.swiftCode).joined(separator: ", ") + ")"
    }
}

extension ObjectExpression {
    var swiftCode: String {
        "[" + properties.map(\.swiftCode).joined(separator: "\n").split(separator: "\n").map({"\t" + $0}).joined(separator: "\n") + "]"
    }
}

extension AssignmentExpression {
    var swiftCode: String {
        left.swiftCode + " " + `operator` + " " + right.swiftCode
    }
}

extension Property {
    var swiftCode: String {
        key.swiftCode + " : " + value!.swiftCode + ","
    }
}

extension ForInStatement {
    var swiftCode: String {
        guard let variableDeclaration = left.node as? VariableDeclaration,
              let variableDeclarator = variableDeclaration.declarations.first,
              let identifier = variableDeclarator.id.node as? Identifier
        else {
            fatalError()
        }
        
        
        
        return "for \(identifier.swiftCode) in JST.keys(\(right.swiftCode)) {\n\(body.swiftCode)\n}"
    }
}

extension ForOfStatement {
    var swiftCode: String {
        guard let variableDeclaration = left.node as? VariableDeclaration,
              let variableDeclarator = variableDeclaration.declarations.first,
              let identifier = variableDeclarator.id.node as? Identifier
        else {
            fatalError()
        }
                
        return "for \(identifier.swiftCode) in JST.values(\(right.swiftCode)) {\n\(body.swiftCode)\n}"
    }
}

extension ForStatement {
    var swiftCode: String {
        return "if true {\n\(`init`.swiftCode(suffix: "\n"))while \(test?.swiftCode ?? "true") \(body.swiftCode)\n\(update.swiftCode(suffix: "\n"))}"
    }
}

extension UpdateExpression {
    var swiftCode: String {
        let op: String
        switch `operator` {
        case "++": op = "+"
        case "--": op = "-"
        default: fatalError()
        }
        
        return "JST.update(\(op), \(`prefix`), 1, &\(argument.swiftCode))"
    }
}

extension ArrayExpression {
    var swiftCode: String {
        "[\(elements.map(\.swiftCode).joined(separator: ", "))]"
    }
}

extension UnaryExpression {
    var swiftCode: String {
        if `prefix` {
            return `operator` + argument.swiftCode
        } else {
            return argument.swiftCode + `operator`
        }
    }
}

extension LogicalExpression {
    var swiftCode: String {
        left.swiftCode + " " + `operator` + " " + right.swiftCode
    }
}

extension IfStatement {
    var swiftCode: String {
        
        let block: BlockStatement
        if let consequent = consequent.node as? BlockStatement {
            block = consequent
        } else {
            block = BlockStatement(body: [AnyNode(node: consequent)])
        }
        
        return "if \(test.swiftCode) \(block.swiftCode)\(alternate.swiftCode(prefix: " else "))"
    }
}

extension FunctionExpression {
    var swiftCode: String {
        body.swiftCode(params: params)
    }
}

extension ArrowFunctionExpression {
    var swiftCode: String { body.swiftCode }
}

extension EmptyStatement {
    var swiftCode: String { "" }
}

extension ThisExpression {
    var swiftCode: String { "self" }
}

extension WhileStatement {
    var swiftCode: String {
        "while \(test.swiftCode) \(body.swiftCode)"
    }
}

extension BreakStatement {
    var swiftCode: String { "break" }
}

extension ContinueStatement {
    var swiftCode: String { "continue" }
}

extension TryStatement {
    var swiftCode: String {
        "do \(block.swiftCode)\(handler.swiftCode())\(finalizer.swiftCode())"
    }
}

extension CatchClause {
    var swiftCode: String {
        " catch let \(param.swiftCode) \(body.swiftCode)"
    }
}

extension NewExpression {
    var swiftCode: String {
        callee.swiftCode + "(" + arguments.map(\.swiftCode).joined(separator: ", ") + ")"
    }
}

extension TemplateLiteral {
    var swiftCode: String {
        var contents = ""
        for index in quasis.indices {
            if index > 0 {
                contents += "\\(" + expressions[index-1].swiftCode + ")"
            }
            
            contents += quasis[index].swiftCode
        }
        return contents.swiftCode
    }
}

extension TemplateElement {
    var swiftCode: String { value.swiftCode }
}

extension TemplateElementValue {
    var swiftCode: String { cooked }
}

extension ConditionalExpression {
    var swiftCode: String {
        "\(test.swiftCode) ? \(consequent.swiftCode) : \(alternate.swiftCode)"
    }
}

extension DoWhileStatement {
    var swiftCode: String {
        "repeat \(body.swiftCode) while \(test.swiftCode)"
    }
}

extension ThrowStatement {
    var swiftCode: String {
        "throw \(argument.swiftCode)"
    }
}

extension SwitchStatement {
    var swiftCode: String {
        "switch \(discriminant.swiftCode) {\(cases.swiftCode(prefix: "\n", separator: "\n", suffix: "\n"))}"
    }
}

extension SwitchCase {
    var swiftCode: String {
        "\(test.swiftCode(prefix: "case ", fallback: "default")): \(consequent.swiftCode())"
    }
}

extension ArrayPattern {
    var swiftCode: String {
        "[" + elements.swiftCode(separator: ", ") + "]"
    }
}
