//
//  UtiranceSettingsViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 27.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class UtiranceSettingsViewModel {

    func getCurrentValue(for utiranceSetting: UtiranceSetting) -> Float {
        return Preference.getUtiranceSettingValue(utiranceSetting)
    }

    func setCurrentValue(_ value: Float, for utiranceSetting: UtiranceSetting) {
        var currentValue = utiranceSetting.defaultValue

        for possibleValue in utiranceSetting.possibleValues {
            if abs(value - currentValue) > abs(value - possibleValue) {
                currentValue = possibleValue
            }
        }

        Preference.setUtiranceSettingValue(utiranceSetting, value: currentValue)
    }

    func getCurrentValueString(for utiranceSetting: UtiranceSetting) -> String {
        let value = Preference.getUtiranceSettingValue(utiranceSetting)

        switch utiranceSetting {
        case .rate, .sentenceDelay:
            switch value {
            case utiranceSetting.defaultValue:
                return "Default"
            default:
                let index = (utiranceSetting.possibleValues.firstIndex(of: value) ?? 0) + 1
                return String(index)
            }
        case .pitch:
            switch value {
            case utiranceSetting.minValue:
                return "Low"
            case utiranceSetting.maxValue:
                return "Normal"
            default:
                return String(value)
            }
        }
    }
}

private extension Float {

    func roundTo(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }

}
