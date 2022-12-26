//
//  GenericError.swift
//
//  Created by John Scott on 16/06/2022.
//

import Foundation

struct GenericError: LocalizedError {
    let message: String?
    let file: StaticString
    let line: UInt
    let function: StaticString

    init(_ message: String? = nil, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        self.message = message
        self.file = file
        self.line = line
        self.function = function
    }
    
    var errorDescription: String? {
        let file = URL(fileURLWithPath: file.description)
        return "\(message ?? "Generic error") in \(file.lastPathComponent) \(function) at line \(line)"
    }
}
