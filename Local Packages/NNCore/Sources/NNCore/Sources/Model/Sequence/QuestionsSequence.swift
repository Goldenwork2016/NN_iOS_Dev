//
//  QuestionsSequence.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 10.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct QuestionsSequence: Codable {

    public static let empty: QuestionsSequence = .init(questions: [])

    public var questions: [Question]

    public init(questions: [Question]) {
        self.questions = questions
    }
}

public extension QuestionsSequence {

    func findQuestion(with id: Identifier) -> Question? {

        func findQuestion(with id: Identifier, in questions: [Question]) -> Question? {
            for question in questions {
                if question.id == id {
                    return question
                } else if let child = findQuestion(with: id, in: question.children) {
                    return child
                }
            }

            return nil
        }

        return findQuestion(with: id, in: self.questions)
    }

    func findParentQuestion(for child: Question) -> Question? {
        return findParentQuestion(for: child, in: self.questions)
    }

    private func findParentQuestion(for child: Question, in questions: [Question]) -> Question? {
        for question in questions {
            if question.children.contains(where: { $0.id == child.id }) {
                return question
            }
        }
        let children = questions.compactMap({ $0.children }).joined()
        if children.isEmpty {
            return nil
        } else {
            return self.findParentQuestion(for: child, in: [Question](children))
        }
    }

}
