//
//  NNDateFormatter.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct NNDateFormatter: Codable, Equatable {

    public static let `default` = NNDateFormatter(format: "EEEE, MMM d, yyyy 'at' h:mm a")
    public private(set) var format: String

    private var formatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.format
        dateFormatter.amSymbol = Midday.am.value
        dateFormatter.pmSymbol = Midday.pm.value
        return dateFormatter
    }

    public init(format: String) {
        self.format = format
    }

    public mutating func updateFormat(_ format: String) {
        self.format = format
    }

}

// MARK: - Check components in format
public extension NNDateFormatter {

    var containsDate: Bool {
        return self.format.lowercased().contains("y") && self.format.lowercased().contains("m") && self.format.lowercased().contains("d")
    }

    var containsTime: Bool {
        return self.format.lowercased().contains("h") && self.format.lowercased().contains("m")
    }

}

// MARK: - Converting
public extension NNDateFormatter {

    func string(from date: Date) -> String {
        var string = self.formatter.string(from: date)

        Midday.allCases.forEach {
            string = string.replacingOccurrences(of: $0.value.uppercased(), with: $0.value.lowercased())
        }

        return string
    }

    func date(from string: String) -> Date? {
        return self.formatter.date(from: string)
    }

}
