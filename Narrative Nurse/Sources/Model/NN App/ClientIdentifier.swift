//
//  Patient.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

public enum ClientIdentifier: Codable, Hashable {
    
    case room(number: Int, section: RoomSection)
    case emoji(emoji: Emoji)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        if let number = try? container.decode(Int.self, forKey: .number),
           let section = try? container.decode(RoomSection.self, forKey: .section) {
            self = .room(number: number, section: section)
        }
        else if let emoji = try? container.decode(Emoji.self, forKey: .emoji) {
            self = .emoji(emoji: emoji)
        }
        else {
            throw NNError(title: "Data Structure Error", description: "Cannot parse `Patient` object")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        switch self {
        case .room(number: let number, section: let section):
            try container.encode(number, forKey: .number)
            try container.encode(section, forKey: .section)
        case .emoji(emoji: let emoji):
            try container.encode(emoji, forKey: .emoji)
        }
    }
    
    enum Keys: String, CodingKey {
        case number
        case section
        case emoji
    }
}

extension ClientIdentifier: Identifiable {
    
    public var id: String {
        switch self {
        case .room(let number, let section):
            return "room \(number) \(section.rawValue)"
        case .emoji(emoji: let emoji):
            return "emoji \(emoji)"
        }
    }
    
}
