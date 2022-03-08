//
//  Number.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 18.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct IrregularForm: Codable, Hashable {

    public var isEmpty: Bool {
        return (self.singular == nil || self.singular == "")
            && (self.plural == nil || self.plural == "")
    }

    public let singular: String?
    public let plural: String?

    public init(singular: String?, plural: String?) {
        self.singular = singular
        self.plural = plural
    }
}
