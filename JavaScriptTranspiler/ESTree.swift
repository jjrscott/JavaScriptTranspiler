//
//  ESTree.swift
//  JavaScriptTranspiler
//
//  Created by John Scott on 18/12/2022.
//

import Foundation

typealias BindingPattern = AnyNode // ArrayPattern | ObjectPattern;
typealias Expression = AnyNode // ThisExpression | Identifier | Literal |
typealias ArrayPatternElement = AnyNode // AssignmentPattern | Identifier | BindingPattern | RestElement | null;
typealias ArrayExpressionElement = AnyNode // Expression | SpreadElement;
typealias FunctionParameter = AnyNode // AssignmentPattern | Identifier | BindingPattern;
typealias ArgumentListElement = AnyNode // Expression | SpreadElement;
typealias Statement = AnyNode // BlockStatement | BreakStatement | ContinueStatement |
typealias Declaration = AnyNode // ClassDeclaration | FunctionDeclaration |  VariableDeclaration;
typealias StatementListItem = AnyNode // Declaration | Statement;
typealias ModuleItem = AnyNode // ImportDeclaration | ExportDeclaration | StatementListItem;
typealias ExportDeclaration = AnyNode // ExportAllDeclaration | ExportDefaultDeclaration | ExportNamedDeclaration;

struct ArrayPattern: Node {
    var elements: [ArrayPatternElement]
}

struct RestElement: Node {
    var argument: AnyNode // Identifier | BindingPattern
}

struct AssignmentPattern: Node {
    var left: AnyNode // Identifier | BindingPattern
    var right: Expression
}

struct ObjectPattern: Node {
    var properties: [Property]
}

struct ThisExpression: Node {
}

struct Identifier: Node {
    var name: String
}

struct Literal: Node {
    var value: RawDecodable // Bool | number | string | RegExp | null
    var raw: String
    var regex: LiteralRegex?
}

struct LiteralRegex: Node {
    var pattern: String
    var flags: String
}

struct ArrayExpression: Node {
    var elements: [ArrayExpressionElement]
}

struct ObjectExpression: Node {
    var properties: [Property]
}

struct Property: Node {
    var key: Expression
    var computed: Bool
    var value: Expression?
    var kind: String // 'get' | 'set' | 'init'
    var method = false
    var shorthand: Bool
}

struct FunctionExpression: Node {
    var id: Identifier?
    var params: [FunctionParameter]
    var body: BlockStatement
    var generator: Bool
    var async: Bool
    var expression: Bool
}

struct ArrowFunctionExpression: Node {
    var id: Identifier?
    var params: [FunctionParameter]
    var body: AnyNode // BlockStatement | Expression
    var generator: Bool
    var async: Bool
    var expression = false
}

struct ClassExpression: Node {
    var id: Identifier?
    var superClass: Identifier?
    var body: ClassBody
}

struct ClassBody: Node {
    var body: [MethodDefinition]
}

struct MethodDefinition: Node {
    var key: Expression?
    var computed: Bool
    var value: FunctionExpression?
    var kind: String // 'method' | 'constructor'
    var `static`: Bool
}

struct TaggedTemplateExpression: Node {
    let tag: Expression
    let quasi: TemplateLiteral
}

struct TemplateElement: Node {
    var value: TemplateElementValue
}

struct TemplateElementValue: Node {
    var cooked: String
    var raw: String
}

struct TemplateLiteral: Node {
    var quasis: [TemplateElement]
    var expressions: [Expression]
}

struct MemberExpression: Node {
    var computed: Bool
    var object: Expression
    var property: Expression
}

struct Super: Node {
}

struct MetaProperty: Node {
    var meta: Identifier
    var property: Identifier
}

struct CallExpression: Node {
    var callee: AnyNode // Expression | Import
    var arguments: [ArgumentListElement]
}

struct NewExpression: Node {
    var callee: Expression
    var arguments: [ArgumentListElement]
}

struct Import: Node {
}

struct SpreadElement: Node {
    var argument: Expression
}

struct UpdateExpression: Node {
    var `operator`: String // '++' | '--'
    var argument: Expression
    var prefix: Bool
}

struct AwaitExpression: Node {
    var argument: Expression
}

struct UnaryExpression: Node {
    var `operator`: String // '+' | '-' | '~' | '!' | 'delete' | 'void' | 'typeof'
    var argument: Expression
    var prefix = true
}

struct BinaryExpression: Node {
    var `operator`: String // 'instanceof' | 'in' | '+' | '-' | '*' | '/' | '%' | '**' | '|' | '^' | '&' | '==' | '!=' | '===' | '!==' | '<' | '>' | '<=' | '<<' | '>>' | '>>>'
    var left: Expression
    var right: Expression
}

struct LogicalExpression: Node {
    var `operator`: String // '||' | '&&'
    var left: Expression
    var right: Expression
}

struct ConditionalExpression: Node {
    var test: Expression
    var consequent: Expression
    var alternate: Expression
}

struct YieldExpression: Node {
    var argument: Expression?
    var delegate: Bool
}

struct AssignmentExpression: Node {
    var `operator`: String // '=' | '*=' | '**=' | '/=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '>>>=' | '&=' | '^=' | '|='
    var left: Expression
    var right: Expression
}

struct SequenceExpression: Node {
    var expressions: [Expression]
}

struct BlockStatement: Node {
    var body: [StatementListItem]
}

struct BreakStatement: Node {
    var label: Identifier?
}

struct ClassDeclaration: Node {
    var id: Identifier?
    var superClass: Identifier?
    var body: ClassBody
}

struct ContinueStatement: Node {
    var label: Identifier?
}

struct DebuggerStatement: Node {
}

struct DoWhileStatement: Node {
    var body: Statement
    var test: Expression
}

struct EmptyStatement: Node {
}

struct ExpressionStatement: Node {
    var expression: Expression
    var directive: String?
}

struct ForStatement: Node {
    var `init`: AnyNode? // Expression | VariableDeclaration | null
    var test: Expression?
    var update: Expression?
    var body: Statement
}

struct ForInStatement: Node {
    var left: Expression
    var right: Expression
    var body: Statement
    var each = false
}

struct ForOfStatement: Node {
    var left: Expression
    var right: Expression
    var body: Statement
}

struct FunctionDeclaration: Node {
    var id: Identifier?
    var params: [FunctionParameter]
    var body: BlockStatement
    var generator: Bool
    var async: Bool
    var expression = false
}

struct IfStatement: Node {
    var test: Expression
    var consequent: Statement
    var alternate: Statement?
}

struct LabeledStatement: Node {
    var label: Identifier
    var body: Statement
}

struct ReturnStatement: Node {
    var argument: Expression?
}

struct SwitchStatement: Node {
    var discriminant: Expression
    var cases: [SwitchCase]
}

struct SwitchCase: Node {
    var test: Expression?
    var consequent: [Statement]
}

struct ThrowStatement: Node {
    var argument: Expression
}

struct TryStatement: Node {
    var block: BlockStatement
    var handler: CatchClause?
    var finalizer: BlockStatement?
}

struct CatchClause: Node {
    var param: AnyNode // Identifier | BindingPattern
    var body: BlockStatement
}

struct VariableDeclaration: Node {
    var declarations: [VariableDeclarator]
    var kind: VariableDeclarationKind // 'var' | 'const' | 'let'
}

enum VariableDeclarationKind: String, Decodable {
    typealias RawValue = String
    
    case `var`
    case `const`
    case `let`
}

struct VariableDeclarator: Node {
    var id: AnyNode // Identifier | BindingPattern
    var `init`: Expression?
}

struct WhileStatement: Node {
    var test: Expression
    var body: Statement
}

struct WithStatement: Node {
    var object: Expression
    var body: Statement
}

//struct Program: Node {
//  var sourceType: 'script'
//  var body: [StatementListItem]
//}
//
//struct Program: Node {
//  var sourceType: 'module'
//  var body: [ModuleItem]
//}

struct Program: Node {
    var sourceType: String
    var body: [AnyNode]
}

struct ImportSpecifier: Node {
    var local: Identifier
    var imported: Identifier?
}

struct ExportAllDeclaration: Node {
    var source: Literal
}

struct ExportDefaultDeclaration: Node {
    var declaration: AnyNode // Identifier | BindingPattern | ClassDeclaration | Expression | FunctionDeclaration
}

struct ExportNamedDeclaration: Node {
    var declaration: AnyNode // ClassDeclaration | FunctionDeclaration | VariableDeclaration
    var specifiers: [ExportSpecifier]
    var source: Literal
}

struct ExportSpecifier: Node {
    var exported: Identifier
    var local: Identifier
}
