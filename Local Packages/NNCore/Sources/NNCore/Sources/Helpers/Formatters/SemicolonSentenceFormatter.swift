//
//  SemicolonSentenceFormatter.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 09.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

final class SemicolonSentenceFormatter: SentenceFormatter {

    func format(sentence: String) -> String {
        guard !sentence.isEmpty else { return sentence }

        return sentence.replacingOccurrences(of: " ;", with: "; ")
    }
}
