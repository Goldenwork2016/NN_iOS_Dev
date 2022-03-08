//
//  KeyValuePair.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 26.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct GlobalSettingItem: Codable {

    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
