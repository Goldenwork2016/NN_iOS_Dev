//
//  KeyValueStorage.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public protocol KeyValueStorage: class {
    func set(_ value: Any?, forKey: String)
    func object(forKey: String) -> Any?
    func data(forKey: String) -> Data?
}
