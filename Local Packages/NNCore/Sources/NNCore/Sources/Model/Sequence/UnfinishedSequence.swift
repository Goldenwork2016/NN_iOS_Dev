//
//  UnfinishedSequence.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 06.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct UnfinishedSequence: Codable {

    public let id: Identifier
    public let facility: Facility
    public let questions: [Question]
    public let answers: [Answer]
    public let displayingQuestions: [Question]
    public let reusableQuestions: [Question]

    public init(id: Identifier, facility: Facility, questions: [Question], answers: [Answer], displayingQuestions: [Question], reusableQuestions: [Question]) {
        self.id = id
        self.facility = facility
        self.questions = questions
        self.answers = answers
        self.displayingQuestions = displayingQuestions
        self.reusableQuestions = reusableQuestions
    }
}
