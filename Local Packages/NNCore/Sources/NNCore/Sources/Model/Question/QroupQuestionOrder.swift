//
//  QroupQuestionElement.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum QroupQuestionOrder: String, Codable, CaseIterable {

    case questionAnswer = "Question/Answer"
    case answerQuestion = "Answer/Question"

    public var title: String {
        self.rawValue
    }
}
