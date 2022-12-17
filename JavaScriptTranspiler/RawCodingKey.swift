//
//  RawCodingKey.swift
//  AnyDecoder
//
//  Created by John Scott on 02/11/2022.
//

import Foundation

enum RawCodingKey: CodingKey, Hashable {
    case stringValue(value: String)
    case intValue(value: Int)
    
    var stringValue: String {
        switch self {
        case .stringValue(let value):
            return value
        case .intValue(let value):
            return value.description
        }
    }
    
    init?(stringValue: String) {
        self = .stringValue(value: stringValue)
    }
    
    var intValue: Int? {
        switch self {
        case .stringValue:
            return nil
        case .intValue(let value):
            return value
        }
    }
    
    init?(intValue: Int) {
        self = .intValue(value: intValue)
    }
}
