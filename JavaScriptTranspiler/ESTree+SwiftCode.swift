//
//  ESTree+SwiftCode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

extension Program {
    func swiftCode(stack: NodeStack) throws -> String {
        try body.swiftCode(stack: stack, separator: "\n", suffix: "\n")
    }
}

extension VariableDeclaration {
    func swiftCode(stack: NodeStack) throws -> String {
        try declarations
            .map { try kind.swiftCode(stack: stack) + " " + $0.swiftCode(stack: stack)}
            .joined(separator: "\n")
    }
}

extension VariableDeclarationKind {
    func swiftCode(stack: NodeStack) throws -> String {
        switch self {
        case .var: return "var"
        case .const:  return "let"
        case .let:  return "var"
        }
    }
}


extension VariableDeclarator {
    func swiftCode(stack: NodeStack) throws -> String {
        try id.swiftCode(stack: stack) + `init`.swiftCode(stack: stack, prefix: stack.stack(with: id).swiftType.swiftCode(prefix: " : ", fallback: " /* \(stack.stack(with: id).path) */") + " = ")
    }
}

extension Identifier {
    func swiftCode(stack: NodeStack) throws -> String {
        name
    }
}

extension Literal {
    func swiftCode(stack: NodeStack) throws -> String {
        switch value {
        case .string(value: let value): return value.swiftQuoteEscape().swiftQuoteWrap()
        case .nil: return "nil"
        default: return raw
        }
    }
}

extension ExpressionStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try expression.swiftCode(stack: stack)
    }
}

extension BinaryExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        switch `operator` {
            //        case "instanceof":
        case "in": return try "JST.contains" + left.swiftCode(stack: stack) + ", " + right.swiftCode(stack: stack) + ")"
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
        case "===": return try left.swiftCode(stack: stack) + " == " + right.swiftCode(stack: stack)
        case "!==": return try left.swiftCode(stack: stack) + " != " + right.swiftCode(stack: stack)
            //        case "<":
            //        case ">":
            //        case "<=":
            //        case "<<":
            //        case ">>":
            //        case ">>>":
        default: return try left.swiftCode(stack: stack) + " " + `operator` + " " + right.swiftCode(stack: stack)
        }
    }
}

extension BlockStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try swiftCode(stack: stack, params: [])
    }
    
    func swiftCode(stack: NodeStack, params: [FunctionParameter]) throws -> String {
        try "{" + params.swiftCode(stack: stack, separator: ", ", suffix: " in") + body.swiftCode(stack: stack, prefix: "\n", separator: "\n", suffix: "\n") + "}"
    }
}

extension FunctionDeclaration {
    func swiftCode(stack: NodeStack) throws -> String {
        if let id {
            let stack = stack.stack(with: id)
            let paramsSwiftCode = try params.map {
                try "_ \($0.swiftCode(stack: stack)): \(stack.stack(with: $0).swiftType.swiftCode(fallback: "/* \(stack.stack(with: $0).path) */ Any"))"
            }.joined(separator: ", ")

            return try "func " + id.swiftCode(stack: stack) + stack.stack(with: "@generic").swiftType.swiftCode(prefix: "<", suffix: ">") + "("+paramsSwiftCode+")\(`async` ? " async" : "") \(stack.stack(with: "@return").swiftType.swiftCode(prefix: "-> ")) " + body.swiftCode(stack: stack)
        } else {
            fatalError()
        }
    }
}

extension ReturnStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "return\(argument.swiftCode(stack: stack, prefix: " "))"
    }
}

extension MemberExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        if computed {
            return try object.swiftCode(stack: stack) + "[" + property.swiftCode(stack: stack) + "]"
        } else {
            return try object.swiftCode(stack: stack) + "." + property.swiftCode(stack: stack)
        }
    }
}

extension CallExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try callee.swiftCode(stack: stack) + "(" + arguments.map({ try $0.swiftCode(stack: stack) }).joined(separator: ", ") + ")"
    }
}

extension ObjectExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try "[" + properties.swiftCode(stack: stack, separator: "\n") + "]"
    }
}

extension AssignmentExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try left.swiftCode(stack: stack) + " " + `operator` + " " + right.swiftCode(stack: stack.stack(with: left))
    }
}

extension Property {
    func swiftCode(stack: NodeStack) throws -> String {
        try key.swiftCode(stack: stack) + " : " + value!.swiftCode(stack: stack) + ","
    }
}

extension ForInStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        guard let variableDeclaration = left.node as? VariableDeclaration,
              let variableDeclarator = variableDeclaration.declarations.first,
              let identifier = variableDeclarator.id.node as? Identifier
        else {
            fatalError()
        }
        
        
        
        return try "for \(identifier.swiftCode(stack: stack)) in JST.keys(\(right.swiftCode(stack: stack))) {\n\(body.swiftCode(stack: stack))\n}"
    }
}

extension ForOfStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        guard let variableDeclaration = left.node as? VariableDeclaration,
              let variableDeclarator = variableDeclaration.declarations.first,
              let identifier = variableDeclarator.id.node as? Identifier
        else {
            fatalError()
        }
                
        return try "for \(identifier.swiftCode(stack: stack)) in JST.values(\(right.swiftCode(stack: stack))) {\n\(body.swiftCode(stack: stack))\n}"
    }
}

extension ForStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        return try "if true {\n\(`init`.swiftCode(stack: stack, suffix: "\n"))while \(test?.swiftCode(stack: stack) ?? "true") \(body.swiftCode(stack: stack))\n\(update.swiftCode(stack: stack, suffix: "\n"))}"
    }
}

extension UpdateExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        let op: String
        switch `operator` {
        case .increment: op = "+"
        case .decrement: op = "-"
        }
        
        return try "JST.update(\(op), \(`prefix`), 1, &\(argument.swiftCode(stack: stack)))"
    }
}

extension ArrayExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try "[\(elements.map({ try $0.swiftCode(stack: stack) }).joined(separator: ", "))]"
    }
}

extension UnaryExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        if `prefix` {
            return try `operator` + argument.swiftCode(stack: stack)
        } else {
            return try argument.swiftCode(stack: stack) + `operator`
        }
    }
}

extension LogicalExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try left.swiftCode(stack: stack) + " " + `operator` + " " + right.swiftCode(stack: stack)
    }
}

extension IfStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        
        let block: BlockStatement
        if let consequent = consequent.node as? BlockStatement {
            block = consequent
        } else {
            block = BlockStatement(body: [AnyNode(node: consequent)])
        }
        
        return try "if \(test.swiftCode(stack: stack)) \(block.swiftCode(stack: stack))\(alternate.swiftCode(stack: stack,prefix: " else "))"
    }
}

extension FunctionExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try body.swiftCode(stack: stack, params: params)
    }
}

extension ArrowFunctionExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try body.swiftCode(stack: stack)
    }
}

extension EmptyStatement {
    func swiftCode(stack: NodeStack) throws -> String { "" }
}

extension ThisExpression {
    func swiftCode(stack: NodeStack) throws -> String { "self" }
}

extension WhileStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "while \(test.swiftCode(stack: stack)) \(body.swiftCode(stack: stack))"
    }
}

extension BreakStatement {
    func swiftCode(stack: NodeStack) throws -> String { "break" }
}

extension ContinueStatement {
    func swiftCode(stack: NodeStack) throws -> String { "continue" }
}

extension TryStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "do \(block.swiftCode(stack: stack))\(handler.swiftCode(stack: stack))\(finalizer.swiftCode(stack: stack))"
    }
}

extension CatchClause {
    func swiftCode(stack: NodeStack) throws -> String {
        try " catch let \(param.swiftCode(stack: stack)) \(body.swiftCode(stack: stack))"
    }
}

extension NewExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try callee.swiftCode(stack: stack) + "(" + arguments.map({ try $0.swiftCode(stack: stack) }).joined(separator: ", ") + ")"
    }
}

extension TemplateLiteral {
    func swiftCode(stack: NodeStack) throws -> String {
        var contents = ""
        for index in quasis.indices {
            if index > 0 {
                contents += try "\\(" + expressions[index-1].swiftCode(stack: stack) + ")"
            }
            
            contents += try quasis[index].swiftCode(stack: stack)
        }
        return contents.swiftQuoteWrap()
    }
}

extension TemplateElement {
    func swiftCode(stack: NodeStack) throws -> String {
        try value.swiftCode(stack: stack).swiftQuoteEscape()
    }
}

extension TemplateElementValue {
    func swiftCode(stack: NodeStack) throws -> String {
        cooked
    }
}

extension ConditionalExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try "\(test.swiftCode(stack: stack)) ? \(consequent.swiftCode(stack: stack)) : \(alternate.swiftCode(stack: stack))"
    }
}

extension DoWhileStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "repeat \(body.swiftCode(stack: stack)) while \(test.swiftCode(stack: stack))"
    }
}

extension ThrowStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "throw \(argument.swiftCode(stack: stack))"
    }
}

extension SwitchStatement {
    func swiftCode(stack: NodeStack) throws -> String {
        try "switch \(discriminant.swiftCode(stack: stack)) {\(cases.swiftCode(stack: stack, prefix: "\n", separator: "\n", suffix: "\n"))}"
    }
}

extension SwitchCase {
    func swiftCode(stack: NodeStack) throws -> String {
        try "\(test.swiftCode(stack: stack, prefix: "case ", fallback: "default")): \(consequent.swiftCode(stack: stack))"
    }
}

extension ArrayPattern {
    func swiftCode(stack: NodeStack) throws -> String {
        try "[" + elements.swiftCode(stack: stack, separator: ", ") + "]"
    }
}

extension ClassDeclaration {
    func swiftCode(stack: NodeStack) throws -> String {
        if let id {
            let stack = stack.stack(with: id)
            return try "class \(id.swiftCode(stack: stack))\(superClass.swiftCode(stack: stack, prefix: " : ")) \(body.swiftCode(stack: stack))"
        } else {
            fatalError()
        }
    }
}

extension ClassBody {
    func swiftCode(stack: NodeStack) throws -> String {
        try "{" + body.swiftCode(stack: stack, prefix: "\n", separator: "\n", suffix: "\n") + "}"
    }
}

extension MethodDefinition {
    func swiftCode(stack: NodeStack) throws -> String {
        guard let value else {
            fatalError()
        }
                
        switch kind {
        case .method:
            let stack = stack.stack(with: key!)
            let paramsSwiftCode = try value.params.map {
                try "_ \($0.swiftCode(stack: stack)): \(stack.stack(with: $0).swiftType.swiftCode(fallback: "/* \(stack.stack(with: $0).path) */ Any"))"
            }.joined(separator: ", ")
            return try "\(stack.stack(with: "@prefix").swiftType.swiftCode(suffix: " "))\(`static` ? "static " : "")func \(key.swiftCode(stack: stack))\(stack.stack(with: "@generic").swiftType.swiftCode(prefix: "<", suffix: ">"))(\(paramsSwiftCode)) \(stack.stack(with: "@return").swiftType.swiftCode(prefix: "-> ")) \(value.body.swiftCode(stack: stack))"
        case .constructor:
            let stack = stack.stack(with: "init")
            let paramsSwiftCode = try value.params.map {
                try "_ \($0.swiftCode(stack: stack)): \(stack.stack(with: $0).swiftType.swiftCode(fallback: "/* \(stack.stack(with: $0).path) */ Any"))"
            }.joined(separator: ", ")
            return try "\(stack.stack(with: "@prefix").swiftType.swiftCode(suffix: " "))init\(stack.stack(with: "@generic").swiftType.swiftCode(prefix: "<", suffix: ">"))(\(paramsSwiftCode)) \(value.body.swiftCode(stack: stack))"
        }
    }
}

extension Super {
    func swiftCode(stack: NodeStack) throws -> String {
        "super"
    }
}

extension AwaitExpression {
    func swiftCode(stack: NodeStack) throws -> String {
        try "await " + argument.swiftCode(stack: stack)
    }
}
