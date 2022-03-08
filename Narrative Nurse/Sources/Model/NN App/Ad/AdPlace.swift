//
//  Ad.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 23.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

enum AdPlace: String {
    case sequence = "SequenceBottom"
    case beforeResult = "BeforeResults"
    case result1 = "Result_1"
    case result2 = "Result_2"

    var placement: String {
        return self.rawValue
    }
}
