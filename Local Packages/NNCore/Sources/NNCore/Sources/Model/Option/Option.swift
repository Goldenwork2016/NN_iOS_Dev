//
//  Option.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 27.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Option: Codable, Equatable, Hashable {

    public static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.id == rhs.id
    }

    enum Keys: String, CodingKey {
        case title
        case narrative
        case repetitiveId
        case polygon
        case id
        case unit
        case none
        case children
        case options
        case beforeGroup
        case afterGroup
    }

    public let kind: Kind
    public let narrative: String
    public let id: Identifier

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.narrative = try container.decode(String.self, forKey: .narrative)

        if let isNone = try? container.decode(Bool.self, forKey: .none), isNone, let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .none(title: title)
        } else if let children = try? container.decode([Option].self, forKey: .children), let options = try? container.decode([Option].self, forKey: .options),
                  let beforeGroup = try? container.decode(IrregularForm.self, forKey: .beforeGroup),
                  let afterGroup = try? container.decode(IrregularForm.self, forKey: .afterGroup),
                  let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: options)
        } else if let title = try? container.decode(String.self, forKey: .title), let children = try? container.decode([Option].self, forKey: .children) {
            self.kind = .groupedOverride(title: title, children: children)
        } else if let repetitiveId = try? container.decode(Identifier.self, forKey: .repetitiveId), let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .repetitive(id: repetitiveId, title: title)
        } else if let unit = try? container.decode(String.self, forKey: .unit), let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .size(title: title, unit: unit)
        } else if let polygon = try? container.decode([Double].self, forKey: .polygon), let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .polygon(polygon: polygon, title: title)
        } else if let title = try? container.decode(String.self, forKey: .title) {
            self.kind = .text(title: title)
        } else {
            assertionFailure("Parsing error: Unsupported option kind")
            self.kind = .text(title: "")
        }
    }

    public init(kind: Kind, narrative: String, id: Identifier) {
        self.kind = kind
        self.narrative = narrative
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.narrative, forKey: .narrative)
        switch self.kind {
        case .none(let title):
            try container.encode(true, forKey: .none)
            try container.encode(title, forKey: .title)
        case .grouped(let title, let beforeGroup, let afterGroup, let children, let options):
            try container.encode(title, forKey: .title)
            try container.encode(children, forKey: .children)
            try container.encode(options, forKey: .options)
            try container.encode(beforeGroup, forKey: .beforeGroup)
            try container.encode(afterGroup, forKey: .afterGroup)
        case .groupedOverride(let title, let children):
            try container.encode(title, forKey: .title)
            try container.encode(children, forKey: .children)
        case .polygon(let value, let title):
            try container.encode(value, forKey: .polygon)
            try container.encode(title, forKey: .title)
        case .text(let title):
            try container.encode(title, forKey: .title)
        case .repetitive(let repetitiveId, let repetitiveTitle):
            try container.encode(repetitiveId, forKey: .repetitiveId)
            try container.encode(repetitiveTitle, forKey: .title)
        case .size(let title, let unit):
            try container.encode(title, forKey: .title)
            try container.encode(unit, forKey: .unit)
        }
    }
}
