//
//  Codable+JSON.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public extension Decodable {

    static func decode(from jsonObject: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: jsonObject)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(Self.self, from: data)
    }
}

public extension Encodable {

    func jsonObject() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(self)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EncodingError.invalidValue(self, EncodingError.Context.init(codingPath: [],
                                                                              debugDescription: "Unable to encode into json object"))
        }
        return json
    }

    func jsonObject(excludeValuesWithKeys keys: [String]) throws -> [String: Any] {
        var json = try jsonObject()

        for key in keys {
            json.removeValue(forKey: key)
        }

        return json
    }

}
