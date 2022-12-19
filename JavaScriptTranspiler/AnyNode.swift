//
//  AnyNode.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

struct AnyNode {
    let node: any Node
}

extension AnyNode: Node {
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let nodeType = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        let swiftTypes: [any Node.Type] = [
            ArrayExpression.self,
            ArrayPattern.self,
            ArrowFunctionExpression.self,
            AssignmentExpression.self,
            AssignmentPattern.self,
            AwaitExpression.self,
            BinaryExpression.self,
            BlockStatement.self,
            BreakStatement.self,
            CallExpression.self,
            CatchClause.self,
            ClassBody.self,
            ClassDeclaration.self,
            ClassExpression.self,
            ConditionalExpression.self,
            ContinueStatement.self,
            DebuggerStatement.self,
            DoWhileStatement.self,
            EmptyStatement.self,
            ExportAllDeclaration.self,
            ExportDefaultDeclaration.self,
            ExportNamedDeclaration.self,
            ExportSpecifier.self,
            ExpressionStatement.self,
            ForInStatement.self,
            ForOfStatement.self,
            ForStatement.self,
            FunctionDeclaration.self,
            FunctionExpression.self,
            Identifier.self,
            IfStatement.self,
            Import.self,
            ImportSpecifier.self,
            LabeledStatement.self,
            Literal.self,
            LogicalExpression.self,
            MemberExpression.self,
            MetaProperty.self,
            MethodDefinition.self,
            NewExpression.self,
            ObjectExpression.self,
            ObjectPattern.self,
            Program.self,
            Program.self,
            Property.self,
            RestElement.self,
            ReturnStatement.self,
            SequenceExpression.self,
            SpreadElement.self,
            Super.self,
            SwitchCase.self,
            SwitchStatement.self,
            TaggedTemplateExpression.self,
            TemplateElement.self,
            TemplateLiteral.self,
            ThisExpression.self,
            ThrowStatement.self,
            TryStatement.self,
            UnaryExpression.self,
            UpdateExpression.self,
            VariableDeclaration.self,
            VariableDeclarator.self,
            WhileStatement.self,
            WithStatement.self,
            YieldExpression.self,
        ]
        
        guard let swiftType = swiftTypes.first(where: { "\($0)" == nodeType }) else {
            fatalError("Unknown type: \(nodeType)")
        }
        
        node = try swiftType.init(from: decoder)
    }
    
    var swiftCode: String { node.swiftCode }
}
