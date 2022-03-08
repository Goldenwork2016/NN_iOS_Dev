//
//  UppercaseUfferDotSentenceFormatter.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

final class UppercaseUfterDotSentenceFormatter: SentenceFormatter {

    func format(sentence: String) -> String {
        let sentences = sentence.sentences.map {
            $0.capitalizingFirstLetter()
        }

        return sentences.joined(separator: String.sentenceSepatator)
    }

}
