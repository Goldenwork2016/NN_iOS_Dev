//
//  RoomSection.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum RoomSection: String, Codable, CaseIterable {
    case a
    case b
    case c
    case d
    
    public var title: String {
        return self.rawValue.capitalized
    }
}
