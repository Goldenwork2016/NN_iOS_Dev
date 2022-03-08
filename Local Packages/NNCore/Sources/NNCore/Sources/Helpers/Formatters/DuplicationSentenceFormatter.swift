//
//  DuplicationSentenceFormatter.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 16.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

final class DuplicationSentenceFormatter: SentenceFormatter {
    func format(sentence: String) -> String {
        guard !sentence.isEmpty else { return sentence }

        let symbols: [String.Element] = [" ", "."]

        var result = sentence
        symbols.forEach { (symbol) in
            result = result.withoutDuplicates(symbol)
        }
        return result
    }
}

private extension String {

    func withoutDuplicates(_ element: String.Element) -> String {

        var copiedSentence = Array(self)

        var index = 0
        while index < copiedSentence.count {
            if copiedSentence[safe: index] == element && copiedSentence[safe: index + 1] == element {
                copiedSentence.remove(at: index)
            } else {
                index += 1
            }
        }

        return String(copiedSentence)
    }
}
