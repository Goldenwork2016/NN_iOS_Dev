//
//  Narrative.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 11.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct Narrative: Codable, Equatable {

    public static func == (lhs: Narrative, rhs: Narrative) -> Bool {
        let isBeforeEquel: Bool
        if let lBefore = lhs.before, let rBefore = rhs.before {
            isBeforeEquel = (lBefore.isEmpty && rBefore.isEmpty) || lBefore == rBefore
        } else if lhs.before == nil, rhs.before == nil {
            isBeforeEquel = true
        } else {
            isBeforeEquel = false
        }

        let isAfterEquel: Bool
        if let lAfter = lhs.after, let rAfter = rhs.after {
            isAfterEquel = (lAfter.isEmpty && rAfter.isEmpty) || lAfter == rAfter
        } else if lhs.after == nil, rhs.after == nil {
            isAfterEquel = true
        } else {
            isAfterEquel = false
        }

        return lhs.afterChildren == rhs.afterChildren && isBeforeEquel && isAfterEquel
    }

    public let before: IrregularForm?
    public let after: IrregularForm?
    public let afterChildren: String?

    public init(before: IrregularForm?, after: IrregularForm?, afterChildren: String?) {
        self.before = before
        self.after = after
        self.afterChildren = afterChildren
    }
}
