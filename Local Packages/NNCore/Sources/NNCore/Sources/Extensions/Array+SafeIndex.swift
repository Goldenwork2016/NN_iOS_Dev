//
//  Array+SafeIndex.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik
//  Copyright © 2020 Slavik Voloshyn. All rights reserved.
//

import Foundation

public extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
