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
        case .string(value: let value): return "\"\(value)\""
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
        "{" + (params.count > 0 ? params.map(\.swiftCode).joined(separator: ", ") + " in" : "") + "\n" + body.map(\.swiftCode).joined(separator: "\n").split(separator: "\n").map({"\t" + $0}).joined(separator: "\n") + "\n}"
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
        "[" + properties.map(\.swiftCode).joined(separator: "\n") + "]"
    }
}

extension AssignmentExpression {
    var swiftCode: String {
        left.swiftCode + " " + `operator` + " " + right.swiftCode
    }
}

extension Property {
    var swiftCode: String {
        "\"" + key.swiftCode + "\"" + " : " + value!.swiftCode + ","
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
        
        
        
        return "for \(identifier.swiftCode) in JST.elements(\(right.swiftCode)) {\n\(body.swiftCode)\n}"
    }
}

extension ForStatement {
    var swiftCode: String {
        return "\(`init`.swiftCode(suffix: "\n"))while \(test?.swiftCode ?? "true") {\n\(body.swiftCode)\n\(update.swiftCode(suffix: "\n"))}"
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
        
        return "JST.update(\(op), \(`prefix`), &\(argument.swiftCode))"
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
        "if \(test.swiftCode) \(consequent.swiftCode)\(alternate.swiftCode(prefix: " else "))"
    }
}

extension FunctionExpression {
    var swiftCode: String {
        body.swiftCode(params: params)
    }
}

extension ArrowFunctionExpression {
    var swiftCode: String {
        body.swiftCode(params: params)
    }
}

