//
//  String+Slice.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public extension String {

    func slice(from: String, to: String) -> String? {

        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

public extension StringProtocol {

    func ranges(of targetString: Self, options: String.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {

        let result: [Range<String.Index>] = self.indices.compactMap { startIndex in
            let targetStringEndIndex = index(startIndex, offsetBy: targetString.count, limitedBy: endIndex) ?? endIndex
            return range(of: targetString, options: options, range: startIndex..<targetStringEndIndex, locale: locale)
        }
        return result
    }

}

public extension String {
    static var sentenceSepatator = ". "

    var sentences: [String] {
        return self.components(separatedBy: String.sentenceSepatator)
    }
}

public extension String {

    func capitalizingFirstLetter() -> String {
        guard !self.isEmpty else {
            return self
        }

        return self.prefix(1).capitalized + dropFirst()
    }

}
