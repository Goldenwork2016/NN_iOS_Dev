//
//  Answer.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 28.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct Answer: Codable {

    public let question: Question
    public let selectedOptions: [Option]

    public init(question: Question, selectedOptions: [Option]) {
        self.question = question
        self.selectedOptions = selectedOptions
    }
}
