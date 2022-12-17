//
//  RawDecodable.swift
//  AnyDecoder
//
//  Created by John Scott on 02/11/2022.
//

import Foundation

enum RawDecodable: Decodable, Hashable {
    case string(value: String)
    case int(value: Int)
    case bool(value: Bool)
    case data(value: Data)
    case double(value: Double)
    case dictionary(value: [RawCodingKey: RawDecodable])
    case array(value: [RawDecodable])
    case `nil`

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: RawCodingKey.self) {
            var value = [RawCodingKey: RawDecodable]()
            for key in container.allKeys {
                value[key] = try container.decode(RawDecodable.self, forKey: key)
            }
            self = .dictionary(value: value)
        } else if var container = try? decoder.unkeyedContainer() {
            var value = [RawDecodable]()
            while !container.isAtEnd {
                value.append(try container.decode(RawDecodable.self))
            }
            self = .array(value: value)
        } else if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(String.self) {
                self = .string(value: value)
            } else if let value = try? container.decode(Int.self) {
                self = .int(value: value)
            } else if let value = try? container.decode(Bool.self) {
                self = .bool(value: value)
            } else if let value = try? container.decode(Data.self) {
                self = .data(value: value)
            } else if let value = try? container.decode(Double.self) {
                self = .double(value: value)
            } else if container.decodeNil() {
                self = .nil
            } else {
                fatalError()
            }
        } else {
            fatalError()
        }
    }
}
