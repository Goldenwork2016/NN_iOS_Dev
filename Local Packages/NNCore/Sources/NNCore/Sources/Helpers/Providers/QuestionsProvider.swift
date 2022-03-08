//
//  QuestionsProvider.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 12.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public final class QuestionsProvider {

    public let ruleEvaluatorProvider: RuleEvaluatorProvider

    public init(ruleEvaluatorProvider: RuleEvaluatorProvider) {
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
    }

    public func nextQuestion(for question: Question, questions: [Question], answers: [Answer], shouldIgnoreVariableQuestion: Bool = true) -> Question? {
        if let childQuestion = self.findNextChildQuestion(for: question, answers: answers, shouldIgnoreVariableQuestion: shouldIgnoreVariableQuestion) {
            return childQuestion
        } else {
            if let parentQuestion = self.findParentQuestion(for: question, in: questions) {
                return self.nextQuestion(for: parentQuestion, questions: questions, answers: answers, shouldIgnoreVariableQuestion: shouldIgnoreVariableQuestion)
            }
        }

        return nil
    }

    public func findNextRootQuestion(in questions: [Question], answers: [Answer], shouldIgnoreVariableQuestion: Bool = true) -> Question? {
        let shownQuestionsIds = answers.compactMap({ $0.question.id })
        for question in questions {
            let wasShown = shownQuestionsIds.contains(question.id)

            if question.kind.isVariables && !shouldIgnoreVariableQuestion && !wasShown {
                return question
            } else if !wasShown && !question.kind.isVariables {
                return question
            }
        }

        return nil
    }

    public func checkIsRepetitive(question: Question, answers: [Answer]) -> Identifier? {
        guard let answer = answers.first(where: { $0.question.id == question.id }),
            let selectedOption = answer.selectedOptions.first
            else { return nil }

        if case Option.Kind.repetitive(let id, _) = selectedOption.kind {
            return id
        } else {
            return nil
        }
    }

    public func findRepetitiveQuestion(with id: Identifier, in questions: [Question]) -> Question? {
        let question = questions.first(where: { $0.id == id })

        if let question = question {
            return Question.prepareReusableQuestion(question)
        } else {
            var children: [Question] = []
            for question in questions {
                children.append(contentsOf: question.children)
            }
            guard !children.isEmpty else { return nil }
            return self.findRepetitiveQuestion(with: id, in: children)
        }
    }

    private func findNextChildQuestion(for question: Question, answers: [Answer], shouldIgnoreVariableQuestion: Bool) -> Question? {
        let shownQuestionsIds = answers.compactMap { $0.question.id }
        for child in question.children {
            if self.ruleEvaluatorProvider.canShowQuestion(question: child, answers: answers) {
                let wasShown = shownQuestionsIds.contains(child.id)

                if child.kind.isVariables && !shouldIgnoreVariableQuestion && !wasShown {
                    return child
                } else if !wasShown && !child.kind.isVariables {
                    return child
                }
            }
        }

        return nil
    }

    private func findParentQuestion(for question: Question, in questions: [Question]) -> Question? {
        var copiedQuestions = questions
        copiedQuestions.removeAll(where: { $0.children.isEmpty })

        let parentQuestion = copiedQuestions.first(where: { $0.children.contains(where: { $0.id == question.id }) })

        if let parentQuestion = parentQuestion {
            return parentQuestion
        } else {
            var subChildren: [Question] = []
            for subQuestion in copiedQuestions {
                subChildren.append(contentsOf: subQuestion.children)
            }
            guard !subChildren.isEmpty else { return nil }
            return self.findParentQuestion(for: question, in: subChildren)
        }
    }
}
