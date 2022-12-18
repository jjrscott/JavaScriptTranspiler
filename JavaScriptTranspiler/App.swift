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
//            print(program)
            print(program.swiftCode)
        }
    }
        
    static let source = #"""
const myImage = document.querySelector("img");

myImage.onclick = () => {
  const mySrc = myImage.getAttribute("src");
  if (mySrc === "images/firefox-icon.png") {
    myImage.setAttribute("src", "images/firefox2.png");
  } else {
    myImage.setAttribute("src", "images/firefox-icon.png");
  }
};
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

