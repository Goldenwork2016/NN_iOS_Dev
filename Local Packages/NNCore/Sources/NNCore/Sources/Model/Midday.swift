//
//  Midday.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum Midday: String, Codable, CaseIterable {

    case am = "a.m."
    case pm = "p.m."

    public var value: String {
        return self.rawValue
    }

    public var index: Int {
        return Midday.allCases.firstIndex(of: self) ?? -1
    }
}
