//
//  Settings.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

public enum Preference {

    @InternalStorage(key: "job-title", defaultValue: .rn)
    public static var jobTitle: JobTitle
    
    @InternalStorage(key: "job-has-been-selected", defaultValue: false)
    public static var jobTitleHasBeenSelected: Bool
}

// MARK: - UtiranceSetting
extension Preference {
    
    public static func getUtiranceSettingValue(_ property: UtiranceSetting) -> Float {
        return getUtiranceInternalStorage(property).wrappedValue
    }

    public static func setUtiranceSettingValue(_ property: UtiranceSetting, value: Float) {
        var storage = getUtiranceInternalStorage(property)
        storage.wrappedValue = value
    }
    
    private static func getUtiranceInternalStorage(_ property: UtiranceSetting) -> InternalStorage<Float> {
        let key = "utirance-setting-\(property.title)"
        return InternalStorage(key: key, defaultValue: property.defaultValue)
    }
}
