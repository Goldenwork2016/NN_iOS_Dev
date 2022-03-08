//
//  File.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

@propertyWrapper
public struct InternalStorage<T: Codable> {
    
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: self.key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return self.defaultValue
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                assertionFailure("Encoding error: \(error)")
                return self.defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: self.key)
            } catch {
                assertionFailure("Encoding error: \(error)")
            }
        }
    }
    
}
