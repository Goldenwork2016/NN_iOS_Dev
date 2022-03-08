//
//  File.swift
//  
//
//  Created by Voloshyn Slavik on 27.11.2020.
//

import Foundation

public enum UtiranceSetting: CaseIterable {

    case rate
    case pitch
    case sentenceDelay

    public var title: String {
        switch self {
        case .rate:
            return "Speed"
        case .pitch:
            return "Pitch"
        case .sentenceDelay:
            return "Sentence Delay"
        }
    }

    public var minValue: Float {
        return self.possibleValues.min() ?? 0
    }

    public var maxValue: Float {
        return self.possibleValues.max() ?? 0
    }

    public var defaultValue: Float {
        switch self {
        case .rate:
            return 0.5
        case .pitch:
            return self.maxValue
        case .sentenceDelay:
            return 0.3
        }
    }

    public var possibleValues: [Float] {
        switch self {
        case .rate:
            return [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6]
        case .pitch:
            return [0.9, 1]
        case .sentenceDelay:
            return [0, 0.3, 0.7, 1, 2]
        }
    }
}
