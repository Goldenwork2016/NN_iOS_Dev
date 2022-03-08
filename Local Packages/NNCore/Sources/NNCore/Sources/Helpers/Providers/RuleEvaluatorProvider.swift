//
//  RuleEvaluatorProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import Expression

private enum RuleFunctions: String {
    case isSelected

    private var arity: Expression.Arity {
        switch self {
        case .isSelected:
            return .exactly(2)
        }
    }
}

final public class RuleEvaluatorProvider {

    public init() {}

    public func canShowQuestion(question: Question, answers: [Answer]) -> Bool {
        do {
            let expression = AnyExpression(question.rule, symbols: [
                .function(RuleFunctions.isSelected.rawValue, arity: .exactly(2)): { args in
                    guard let questionId = args[safe: 0] as? Identifier, !questionId.isEmpty,
                    let optionId = args[safe: 1] as? Identifier, !optionId.isEmpty else {
                        assertionFailure("The rule `\(question.rule)` doesn't have correct params")

                        return false
                    }

                    return answers.getOption(with: questionId, optionId: optionId) != nil
                }
            ])

            return try expression.evaluate()
        } catch {
            assertionFailure("The rule `\(question.rule)` is incorrect")
            return false
        }
    }

}

private extension Array where Element == Answer {

    func getOption(with questionId: Identifier, optionId: Identifier) -> Option? {

        for answer in self where answer.question.id == questionId {
            for option in answer.selectedOptions where option.id == optionId {
                return option
            }
        }

        return nil
    }

}
