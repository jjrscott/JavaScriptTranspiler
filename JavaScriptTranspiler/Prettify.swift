//
//  Prettify.swift
//  
//
//  Created by Monterey on 23/3/22.
//  https://github.com/empft/SwiftSolidityBinding
//

import Foundation
import SwiftFormat
import SwiftFormatConfiguration

func prettify(text: String, assumingFileURL: URL? = nil) throws -> String {
    var configuration = Configuration()
    configuration.indentation = .spaces(4)
        
    let formatter = SwiftFormatter(configuration: configuration)
    var result = ""
    try formatter.format(source: text, assumingFileURL: assumingFileURL, to: &result)
    return result
}
