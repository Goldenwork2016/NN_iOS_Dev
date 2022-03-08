//
//  SequenceFileType.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 23.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum SequenceFileType: String, Codable, CaseIterable {

    case main = "sequence"
    case shared = "reusable"

    public var title: String {
        switch self {
        case .main:
            return "Main Sequences"
        case .shared:
            return "Shared Sequences"
        }
    }
}
