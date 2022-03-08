//
//  QuestionsViewModel.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 12.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore
import Firebase

final class QuestionsViewModel {

    let questionsProvider: QuestionsProvider
    let sequencesProvider: SequencesProvider
    let unfinishedSequencesProvider: UnfinishedSequencesProvider
    let clientIdentifier: ClientIdentifier
    let facility: Facility

    var onComplete: (([Answer]) -> Void)?

    private let sessionId: Identifier
    private(set) var questions: [Question]
    private(set) var answers: [Answer]
    private var displayingQuestions: [Question] = []
    private var reusableQuestions: [Question] = []
    private var skipRemovingLastAnswer = true
    
    var narrative: String {
        let narrativeGenerator = NarrativeGenerator()
        return narrativeGenerator.getNarrative(questions: self.questions, answers: self.answers)
    }

    init(questionsProvider: QuestionsProvider, sequencesProvider: SequencesProvider, unfinishedSequencesProvider: UnfinishedSequencesProvider, questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) {
        self.questionsProvider = questionsProvider
        self.sequencesProvider = sequencesProvider
        self.unfinishedSequencesProvider = unfinishedSequencesProvider
        self.clientIdentifier = clientIdentifier
        
        self.questions = questions
        self.facility = categoryItem
        self.sessionId = UUID().uuidString
        self.displayingQuestions.append(questions[0])
        self.answers = []
        self.skipRemovingLastAnswer = false
        
        self.observeWillTerminateNotification()
    }

    init(questionsProvider: QuestionsProvider, sequencesProvider: SequencesProvider, unfinishedSequencesProvider: UnfinishedSequencesProvider, unfinishedSequence: UnfinishedSequence, clientIdentifier: ClientIdentifier) {
        self.questionsProvider = questionsProvider
        self.sequencesProvider = sequencesProvider
        self.unfinishedSequencesProvider = unfinishedSequencesProvider
        self.clientIdentifier = clientIdentifier
        
        self.sessionId = unfinishedSequence.id
        self.questions = unfinishedSequence.questions
        self.facility = unfinishedSequence.facility
        self.answers = unfinishedSequence.answers
        self.displayingQuestions = unfinishedSequence.displayingQuestions
        self.reusableQuestions = unfinishedSequence.reusableQuestions
        self.skipRemovingLastAnswer = true
        
        self.observeWillTerminateNotification()
    }

    private func observeWillTerminateNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.save),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.save),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.save),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
}

// MARK: - Save
extension QuestionsViewModel {

    @objc func save() {
        let unfinishedSequence = UnfinishedSequence(id: self.sessionId, facility: facility, questions: self.questions, answers: self.answers, displayingQuestions: self.displayingQuestions, reusableQuestions: self.reusableQuestions)
        self.unfinishedSequencesProvider.save(unfinishedSequence: unfinishedSequence, job: Preference.jobTitle, clientIdentifier: self.clientIdentifier)
    }

}

// MARK: - Getters
extension QuestionsViewModel {
    func getQuestion(at index: Int) -> Question? {
        return self.displayingQuestions[safe: index]
    }

    func getNumberOfQuestions() -> Int {
        return self.displayingQuestions.count
    }
}

// MARK: - Answers
extension QuestionsViewModel {
    func addAnswer(options: [Option]) {
        guard let question = self.displayingQuestions.last else { return }

        let answer = Answer(question: question, selectedOptions: options)
        self.answers.append(answer)

        self.addNextQuestionIfAvailable()
    }

    func removeLastAnswer() {
        guard !self.skipRemovingLastAnswer else {
            self.skipRemovingLastAnswer = false
            return
        }
        
        guard !self.answers.isEmpty else { return }
        
        self.answers.removeLast()
    }
}

// MARK: - Questions
extension QuestionsViewModel {
    func removeLastQuestion() {
        if let question = self.displayingQuestions.last, self.reusableQuestions.contains(where: { $0.id == question.id }) {
            for index in self.questions.indices {
                let rootQuestion = self.questions[index]
                if rootQuestion.id == question.id {
                    self.questions.remove(at: index)
                    self.displayingQuestions.removeLast()
                    self.removeLastAnswer()
                    return
                } else if self.checkIfChildrenContains(question: question, children: rootQuestion.children) {
                    var copiedRootQuestion = rootQuestion
                    copiedRootQuestion.removeQuestion(with: question.id)

                    self.questions.remove(at: index)
                    self.questions.insert(copiedRootQuestion, at: index)

                    self.displayingQuestions.removeLast()
                    self.answers.removeLast(2)
                    return
                }
            }
        } else {
            self.displayingQuestions.removeLast()
            self.removeLastAnswer()
        }
    }

    private func nextQuestion() -> Question? {
        guard let lastQuestion = self.displayingQuestions.last else { return nil }

        if let repetitiveId = self.questionsProvider.checkIsRepetitive(question: lastQuestion, answers: self.answers),
            let nextQuestion = self.questionsProvider.findRepetitiveQuestion(with: repetitiveId, in: questions) {
            self.questions.append(nextQuestion)
            return nextQuestion
        }

        if let nextQuestion = self.questionsProvider.nextQuestion(for: lastQuestion, questions: self.questions, answers: self.answers) {
            return nextQuestion
        } else {
            return self.questionsProvider.findNextRootQuestion(in: self.questions, answers: self.answers)
        }
    }

    private func addNextQuestionIfAvailable() {
        guard let nextQuestion = self.nextQuestion() else {
            self.unfinishedSequencesProvider.remove(facility: self.facility, job: Preference.jobTitle, clientIdentifier: self.clientIdentifier)

            self.onComplete?(answers)
            return
        }

        if case Question.Kind.reusable(let filename) = nextQuestion.kind {
            if let question = self.sequencesProvider.loadQuestion(with: filename, from: .project) {

                for index in self.questions.indices {
                    if let rootQuestion = self.questions[safe: index] {
                        if rootQuestion.id == nextQuestion.id {
                            let updatedQuestion = Question.prepareReusableQuestion(question)
                            self.reusableQuestions.append(updatedQuestion)
                            var copiedRootQuestion = rootQuestion
                            copiedRootQuestion.children.append(updatedQuestion)

                            let answer = Answer(question: rootQuestion, selectedOptions: [])
                            self.answers.append(answer)

                            self.questions.remove(at: index)
                            self.questions.insert(copiedRootQuestion, at: index)

                            self.displayingQuestions.append(updatedQuestion)
                            return
                        } else {
                            if self.checkIfChildrenContains(question: nextQuestion, children: rootQuestion.children) {
                                var copiedRootQuestion = rootQuestion
                                let updatedQuestion = Question.prepareReusableQuestion(question)
                                self.reusableQuestions.append(updatedQuestion)
                                copiedRootQuestion.appendQuestion(with: nextQuestion.id, question: updatedQuestion)

                                let answer = Answer(question: nextQuestion, selectedOptions: [])
                                self.answers.append(answer)

                                self.questions.remove(at: index)
                                self.questions.insert(copiedRootQuestion, at: index)

                                self.displayingQuestions.append(updatedQuestion)
                                return
                            }
                        }
                    }
                }
            }
        } else {
            self.displayingQuestions.append(nextQuestion)
        }
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
