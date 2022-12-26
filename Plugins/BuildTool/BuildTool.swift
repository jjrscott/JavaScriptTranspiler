//
//  BuildTool.swift
//  
//
//  Created by John Scott on 24/12/2022.
//

import PackagePlugin
import UniformTypeIdentifiers

@main
struct BuildTool: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        fatalError()
//        return [
//            .prebuildCommand(displayName: "Transpile JavaScript",
//                             executable: try context.tool(named: "JavaScriptTranspiler").path,
//                             arguments: [context.pluginWorkDirectory],
//                             outputFilesDirectory: context.pluginWorkDirectory)
//        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension FileType {
    var argument: String {
        switch self {
        case .source: return "source"
        case .header: return "header"
        case .resource: return "resource"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
}

extension BuildTool: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        var arguments = [CustomStringConvertible]()
                
//        var inputFiles = [Path]()
//        var outputFiles = [Path]()
//
        var commands = [Command]()
        
        for inputFile in target.inputFiles {
            guard inputFile.type == .source && inputFile.path.extension == "js" else {
                continue
            }
            
            let outputFile = context.pluginWorkDirectory.appending(subpath: inputFile.path.stem.appending(".swift"))
            
            arguments.append("--input")
            arguments.append(inputFile.path.string)
            arguments.append("--output")
            arguments.append(outputFile.string)
            
            commands.append(.buildCommand(displayName: "Transpile \(inputFile.path.lastComponent)",
                                          executable: try context.tool(named: "JavaScriptTranspiler").path,
                                          arguments: arguments,
                                         inputFiles: [inputFile.path],
                                         outputFiles: [outputFile]))
        }
        
        return commands
    }
}
#endif
