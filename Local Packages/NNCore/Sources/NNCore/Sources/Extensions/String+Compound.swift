//
//  String+Compound.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 11.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public extension String {

    static func compound(items: [String]) -> String {
        var sentence = ""

        if items.isEmpty {
            return sentence
        } else if items.count == 1 {
            sentence = items.joined()
            return sentence
        } else if items.count == 2 {
            sentence = items.joined(separator: " and ")
            return sentence
        } else {
            var copiedItems = items
            copiedItems.removeLast()
            sentence = copiedItems.joined(separator: ", ")
            if let lastItem = items.last, !lastItem.isEmpty {
                sentence += ", and \(lastItem)"
            } else {
                return String.compound(items: copiedItems)
            }

            return sentence
        }
    }

}
