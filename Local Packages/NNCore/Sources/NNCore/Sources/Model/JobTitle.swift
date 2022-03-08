//
//  JobType.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum JobTitle: String, Codable, CaseIterable, Identifiable {
    
    case rn = "RN"
    case lpn = "LPN"
    case cna = "CNA"
    case hha = "HHA"
    
    public var id: String {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        
        case .rn:
            return "Registered Nurse"
        case .lpn:
            return "Licensed Practical Nurse"
        case .cna:
            return "Certified Nursing Assistant"
        case .hha:
            return "Home Health Aid"
        }
    }
}
