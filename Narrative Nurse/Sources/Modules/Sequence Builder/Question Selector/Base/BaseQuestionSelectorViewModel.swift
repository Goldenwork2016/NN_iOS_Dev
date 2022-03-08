//
//  BaseQuestionSelectorViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

class BaseQuestionSelectorViewModel {

    let sequencesProvider: SequencesProvider
    let questionsSequenceUrl: URL
    let fileType: SequenceFileType

    let questionsSequence: QuestionsSequence

    // All tree questions represented in array
    private var linearQuestionsIds: [Identifier] = []

    // Questions who have childen and are expanded
    private var expandedQuestionsIds: [Identifier] = []

    // All questions that we see at that moment in list
    private var visibleQuestionsIds: [Identifier] = []

    var onUpdate: VoidClosure?

    init(questionsSequenceUrl: URL, fileType: SequenceFileType, sequencesProvider: SequencesProvider) {
        switch fileType {
        case .main:
            self.questionsSequence = sequencesProvider.loadObject(by: questionsSequenceUrl) ?? .empty
        case .shared:
            if let qeustion: Question = sequencesProvider.loadObject(by: questionsSequenceUrl) {
                self.questionsSequence = QuestionsSequence(questions: [qeustion])
            } else {
                self.questionsSequence = .empty
            }
        }

        self.questionsSequenceUrl = questionsSequenceUrl
        self.sequencesProvider = sequencesProvider
        self.fileType = fileType

        formLinearArray()
        expandAllQuestions()
    }

    private func formLinearArray() {
        self.linearQuestionsIds = []
        self.questionsSequence.questions.forEach { item in
            self.linearQuestionsIds += [item.id] + self.appendChildren(from: item).map { $0.id }
        }

        self.visibleQuestionsIds = []
        let expandedQuestions = self.expandedQuestionsIds.compactMap({ self.getQuestion(with: $0) })
        self.linearQuestionsIds.forEach { (questionId) in
            if let question = self.getQuestion(with: questionId),
                expandedQuestions.compactMap({ $0.children }).contains(where: { $0.contains(where: { $0.id == question.id }) }) || self.questionsSequence.questions.contains(where: { $0.id == question.id }) {
                self.visibleQuestionsIds.append(question.id)
            }
        }

        self.onUpdate?()
    }

    private func syncExpandedQuestions() {
        var updatedExpandedQuestion: [Identifier] = []
        for expandedQuestion in self.expandedQuestionsIds {
            if let question = self.question(with: expandedQuestion, in: self.questionsSequence.questions) {
                updatedExpandedQuestion.append(question.id)
            }
        }
        self.expandedQuestionsIds = updatedExpandedQuestion
    }

    private func question(with id: Identifier, in questions: [Question]) -> Question? {
        if let question = questions.first(where: { $0.id == id }) {
            return question
        } else {
            let children = questions.compactMap({ $0.children }).joined()
            if children.isEmpty {
                return nil
            } else {
                return self.question(with: id, in: [Question](children))
            }
        }
    }

    private func appendChildren(from question: Question) -> [Question] {
        var questions: [Question] = []

        question.children.forEach({ questions += [$0] + self.appendChildren(from: $0) })

        return questions
    }

    private func embedLevel(for question: Question, in children: [Question], level: Int) -> Int {
        if children.isEmpty {
            return level
        } else if children.contains(where: { $0.id == question.id }) {
            return level + 1
        } else {
            var subChildren: [Question] = []
            children.forEach { (question) in
                subChildren.append(contentsOf: question.children)
            }
            return self.embedLevel(for: question, in: subChildren, level: level + 1)
        }
    }
}

// MARK: - Getters
extension BaseQuestionSelectorViewModel {
    func getNumberOfQuestions() -> Int {
        return self.visibleQuestionsIds.count
    }

    func getQuestion(at indexPath: IndexPath) -> Question? {
        guard let questionId = self.visibleQuestionsIds[safe: indexPath.row] else {
            return nil
        }

        return getQuestion(with: questionId)
    }

    func getOffsetLevel(at indexPath: IndexPath) -> Int {
        guard let questionId = self.visibleQuestionsIds[safe: indexPath.row],
            let question = getQuestion(with: questionId) else { return 0 }

        return self.embedLevel(for: question, in: self.questionsSequence.questions, level: 0)
    }

    func getQuestion(with id: Identifier) -> Question? {
        return self.questionsSequence.findQuestion(with: id)
    }

}

// MARK: - Expanding/Collapsing cells
extension BaseQuestionSelectorViewModel {
    func expandAllQuestions() {
        self.linearQuestionsIds.forEach { (questionId) in
            if let question = getQuestion(with: questionId),
                !self.isExpanded(question),
                !question.children.isEmpty {
                self.expandCollapse(question)
            }
        }
    }

    func collapseAllQuestions() {
        self.expandedQuestionsIds.removeAll()
        self.formLinearArray()
    }

    func expandAllQuestions(in question: Question) {
        if !self.isExpanded(question), !question.children.isEmpty {
            self.expandCollapse(question)
        }

        question.children.forEach({ self.expandAllQuestions(in: $0) })
    }

    func collapseAllQuestions(in question: Question) {
        self.expandedQuestionsIds.removeAll(where: { $0 == question.id })
        self.expandedQuestionsIds.removeAll(where: { self.checkIfChildrenContains(questionWithId: $0, children: question.children) })

        self.formLinearArray()
    }

    func isExpanded(at indexPath: IndexPath) -> Bool {
        guard let question = self.getQuestion(at: indexPath) else { return false }

        return self.isExpanded(question)
    }

    func isExpanded(_ question: Question) -> Bool {
        return self.expandedQuestionsIds.contains(where: { $0 == question.id })
    }

    func expand(path: [Question]) {
        for question in path {
            if let index = self.visibleQuestionsIds.firstIndex(of: question.id) {
                let indexPath = IndexPath(row: index, section: 0)
                if !self.isExpanded(at: indexPath) {
                    self.expandedQuestionsIds.append(question.id)
                    self.formLinearArray()
                }
            }
        }
    }

    func expandCollapse(at indexPath: IndexPath) {
        guard let question = self.getQuestion(at: indexPath) else { return }

        if self.isExpanded(at: indexPath) {
            self.expandedQuestionsIds.removeAll(where: { $0 == question.id })
            self.expandedQuestionsIds.removeAll(where: { self.checkIfChildrenContains(questionWithId: $0, children: question.children) })
        } else {
            self.expandedQuestionsIds.append(question.id)
        }

        self.formLinearArray()
        self.onUpdate?()
    }

    private func expandCollapse(_ question: Question) {
        if self.isExpanded(question) {
            self.expandedQuestionsIds.removeAll(where: { $0 == question.id })
            self.expandedQuestionsIds.removeAll(where: { self.checkIfChildrenContains(questionWithId: $0, children: question.children) })
        } else {
            self.expandedQuestionsIds.append(question.id)
        }

        self.syncExpandedQuestions()
        self.formLinearArray()
        self.onUpdate?()
    }

    private func checkIfChildrenContains(questionWithId questionId: Identifier, children: [Question]) -> Bool {
        guard let question = getQuestion(with: questionId) else {
            return false
        }

        return checkIfChildrenContains(question: question, children: children)
    }

    private func checkIfChildrenContains(question: Question, children: [Question]) -> Bool {
        if children.isEmpty {
            return false
        } else if children.contains(where: { $0.id == question.id }) {
            return true
        } else {
            var subChildren: [Question] = []
            children.forEach { (question) in
                subChildren.append(contentsOf: question.children)
            }
            return self.checkIfChildrenContains(question: question, children: subChildren)
        }
    }
}
