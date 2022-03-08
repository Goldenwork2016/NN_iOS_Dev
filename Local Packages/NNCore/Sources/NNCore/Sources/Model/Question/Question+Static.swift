//
//  Question+Static.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
// MARK: - Create question
extension Question {

    public static func emptyQuestion(kind: Question.Kind) -> Question {
        let options: [Option]

        switch kind {
        case .list, .dateTime:
            let option = Option(kind: .text(title: ""), narrative: "", id: UUID().uuidString)
            options = [option]
        case .image:
            let option = Option(kind: .polygon(polygon: [], title: ""), narrative: "", id: UUID().uuidString)
            options = [option]
        case .size:
            let option = Option(kind: .size(title: "", unit: ""), narrative: "", id: UUID().uuidString)
            options = [option]
        case .grouped:
            let option = Option(kind: .grouped(title: "New Group", beforeGroup: .init(singular: nil, plural: nil), afterGroup: .init(singular: nil, plural: nil), children: [], options: []), narrative: "", id: UUID().uuidString)
            options = [option]
        default:
            options = []
        }

        let question = Question(id: UUID().uuidString, question: "New Question", narrative: nil, outputToVariable: nil, kind: kind, options: options, rule: "true", children: [])

        return question
    }

}

// MARK: - Prepare reusable question
extension Question {

    public static func prepareReusableQuestion(_ reusableQuestion: Question) -> Question {
        let updateIdsResult = Question.withUpdatedIds(question: reusableQuestion)
        var updatedReusableQuestion = Question.withUpdatedRuleIds(in: updateIdsResult.question, replacemens: updateIdsResult.replacemens)

        let updateVariablesResult = Question.withUpdatedOutputToVariable(question: updatedReusableQuestion)
        updatedReusableQuestion = Question.withUpdatedVariablesToOutput(in: updateVariablesResult.question, replacemens: updateVariablesResult.replacemens)

        return updatedReusableQuestion
    }

    // Replace variable Question.outputToVariable with Question.id
    // Return replacements dictionary key=OldValue, value=NewValue
    private static func withUpdatedOutputToVariable(question: Question) -> (question: Question, replacemens: [String: String]) {
        var replacements: [String: String] = [:]

        let oldVariable: String? = question.outputToVariable
        var newVariable: String?
        if let oldVariable = oldVariable, !oldVariable.isEmpty {
            newVariable = question.id
            replacements[oldVariable] = newVariable
        }

        var updatedChildren = question.children
        for index in updatedChildren.indices {
            let result = Question.withUpdatedOutputToVariable(question: updatedChildren[index])
            result.replacemens.forEach {
                replacements[$0.key] = $0.value
            }
            updatedChildren[index] = result.question
        }

        let updatedQuestion = Question(id: question.id, question: question.question, narrative: question.narrative, outputToVariable: newVariable, kind: question.kind, options: question.options, rule: question.rule, children: updatedChildren)

        return (question: updatedQuestion, replacemens: replacements)
    }

    // Replace Question.kind(.variablesToOutput) with new variables
    private static func withUpdatedVariablesToOutput(in question: Question, replacemens: [String: String]) -> Question {
        let kind: Question.Kind
        if case .variablesToOutput(let variables) = question.kind {
            var newVariables: [String] = []
            for item in variables {
                let variable = replacemens[item] ?? item
                newVariables.append(variable)
            }
            kind = .variablesToOutput(variables: newVariables)
        } else {
            kind = question.kind
        }

        var updatedChildren = question.children
        for index in updatedChildren.indices {
            updatedChildren[index] = Question.withUpdatedVariablesToOutput(in: updatedChildren[index], replacemens: replacemens)
        }

        let updatedQuestion = Question(id: question.id, question: question.question, narrative: question.narrative, outputToVariable: question.outputToVariable, kind: kind, options: question.options, rule: question.rule, children: updatedChildren)

        return updatedQuestion
    }

    // Update question && option ids
    // Return replacements dictionary key=OldId, value=NewId
    private static func withUpdatedIds(question: Question) -> (question: Question, replacemens: [String: String]) {
        var replacements: [String: String] = [:]

        let newQuestionId = UUID().uuidString

        replacements[question.id] = newQuestionId

        var updatedOptions = question.options
        for index in question.options.indices {
            let option = updatedOptions[index]
            let newOptionId = UUID().uuidString
            updatedOptions[index] = Option(kind: option.kind, narrative: option.narrative, id: newOptionId)
            replacements[option.id] = newOptionId
        }

        var updatedChildren = question.children
        for index in updatedChildren.indices {
            let result = Question.withUpdatedIds(question: updatedChildren[index])
            result.replacemens.forEach {
                replacements[$0.key] = $0.value
            }
            updatedChildren[index] = result.question
        }

        let updatedQuestion = Question(id: newQuestionId, question: question.question, narrative: question.narrative, outputToVariable: question.outputToVariable, kind: question.kind, options: updatedOptions, rule: question.rule, children: updatedChildren)

        return (question: updatedQuestion, replacemens: replacements)
    }

    // Update rules with new ids
    private static func withUpdatedRuleIds(in question: Question, replacemens: [String: String]) -> Question {
        var updatedChildren = question.children
        for index in updatedChildren.indices {
            updatedChildren[index] = Question.withUpdatedRuleIds(in: updatedChildren[index], replacemens: replacemens)
        }

        var updatedQuestion = question
        for item in replacemens {
            let updatedRule = updatedQuestion.rule.replacingOccurrences(of: "'\(item.key)'", with: "'\(item.value)'")
            updatedQuestion = Question(id: updatedQuestion.id, question: updatedQuestion.question, narrative: updatedQuestion.narrative, outputToVariable: updatedQuestion.outputToVariable, kind: updatedQuestion.kind, options: updatedQuestion.options, rule: updatedRule, children: updatedChildren)
        }

        return updatedQuestion
    }

}
