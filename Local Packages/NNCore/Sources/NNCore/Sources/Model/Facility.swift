//
//  File.swift
//  
//
//  Created by Voloshyn Slavik on 27.10.2020.
//

import Foundation

public enum Facility: String, CaseIterable, Codable, Hashable, Identifiable {

    case skilled = "Skilled"
    case homeHealth = "HomeHealth"
    case assistedLiving = "AssistedLiving"
    
    public var id: String {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .skilled:
            return "Skilled Nursing / Long Term Care"
        case .homeHealth:
            return "Home Health"
        case .assistedLiving:
            return "Assisted Living"
        }
    }
}
