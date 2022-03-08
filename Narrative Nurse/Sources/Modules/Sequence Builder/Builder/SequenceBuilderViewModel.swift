//
//  SequenceViewModel.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 23.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class SequenceBuilderViewModel {

    enum InsertOption: String, CaseIterable {

        case toSibling = "Sibling"
        case toChild = "Child"

    }

    enum Mode: String, CaseIterable {
        case edit = "Edit"
        case rearrange = "Rearrange"
        case preview = "Preview"
    }

    enum InstertLocation {
        case before(Question)
        case after(Question)

        var question: Question {
            switch self {
            case .before(let question):
                return question
            case .after(let question):
                return question
            }
        }
    }

    let suppportedQuestionsToCreate: [Question.Kind] = [
        .dateTime(formatter: NNDateFormatter.default),
        .size,
        .grouped(linkingVerb: IrregularForm(singular: nil, plural: nil), order: .questionAnswer),
        .variablesToOutput(variables: []),
        .reusable(filename: ""),
        .list(multiselection: false),
        .image(imagePath: "", multiselection: false)
    ]

    let sequencesProvider: SequencesProvider
    let questionsSequenceUrl: URL
    let fileType: SequenceFileType

    private(set) var mode: Mode = .edit
    private(set) var questionsSequence: QuestionsSequence

    var onUpdate: VoidClosure?
    var onUpdateNarrative: VoidClosure?
    var onUpdateSelectedQuestion: VoidClosure?

    // All tree questions represented in array
    private var linearQuestionsIds: [Identifier] = []

    // Questions who have childen and are expanded
    private var expandedQuestionsIds: [Identifier] = []

    // All questions that we see at that moment in list
    private var visibleQuestionsIds: [Identifier] = []

    // Key - id of loaded question from a file
    // Value - original reusable question
    private var originalReusableQuestions: [Identifier: Question] = [:]

    // Current selected question id
    private var selectedQuestionId: Identifier?
    var selectedQuestion: Question? {
        guard let selectedQuestionId = self.selectedQuestionId else {
            return nil
        }

        return self.getQuestion(with: selectedQuestionId)
    }

    private var answers: [Answer] = [] {
        didSet {
            self.onUpdateNarrative?()
        }
    }

    // Key - id of question
    // Value - array of options
    var narrative: String {
        let narrativeGenerator = NarrativeGenerator()
        return narrativeGenerator.getNarrative(questions: self.questionsSequence.questions, answers: self.answers)
    }

    var shouldShowClearButton: Bool {
        return !self.answers.isEmpty
    }

    var shouldShowCollapseButton: Bool {
        return !self.expandedQuestionsIds.isEmpty
    }

    var title: String {
        return self.questionsSequenceUrl.lastPathComponent.removingPercentEncoding ?? ""
    }

    init(questionsSequenceUrl: URL, fileType: SequenceFileType, sequencesProvider: SequencesProvider) {
        var selectedQuestion: Question?
        switch fileType {
        case .main:
            self.questionsSequence = sequencesProvider.loadObject(by: questionsSequenceUrl) ?? .empty
            selectedQuestion = self.questionsSequence.questions.first
        case .shared:
            if let qeustion: Question = sequencesProvider.loadObject(by: questionsSequenceUrl) {
                self.questionsSequence = QuestionsSequence(questions: [qeustion])
                selectedQuestion = qeustion
            } else {
                self.questionsSequence = .empty
            }
        }

        self.questionsSequenceUrl = questionsSequenceUrl
        self.sequencesProvider = sequencesProvider
        self.fileType = fileType

        self.selectQuestion(selectedQuestion)
        self.formLinearArray()
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

    func setMode(with index: Int) {
        guard let newMode = Mode.allCases[safe: index] else {
            assertionFailure()
            return
        }

        self.mode = newMode
    }

    func selectQuestion(_ question: Question?) {
        self.selectedQuestionId = question?.id
        self.onUpdateSelectedQuestion?()
    }

    func updateEditedQuestion(_ editedQuestion: Question) {
        if let oldQuestion = getQuestion(with: editedQuestion.id) {
            self.replace(question: oldQuestion, with: editedQuestion)
        }

        self.syncExpandedQuestions()
        self.formLinearArray()

        self.save()
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

    private func replace(oldQuestion: Question, with newQuestion: Question) {
        guard let index = self.questionsSequence.questions.firstIndex(where: { $0.id == oldQuestion.id }) else { return }

        self.questionsSequence.questions.remove(at: index)
        self.questionsSequence.questions.insert(newQuestion, at: index)
    }

    func syncExpandedQuestions() {
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

    private func deleteQuestion(_ question: Question) {
        if self.questionsSequence.questions.contains(where: { $0.id == question.id }) {
            for index in self.questionsSequence.questions.indices {
                let updatedRootQuestion = self.questionsSequence.questions[index]
                if updatedRootQuestion.id == question.id {
                    self.questionsSequence.questions.remove(at: index)
                    return
                }
            }
        } else {
            for index in self.questionsSequence.questions.indices {
                var updatedRootQuestion = self.questionsSequence.questions[index]
                updatedRootQuestion.removeQuestion(with: question.id)
                self.replace(oldQuestion: updatedRootQuestion, with: updatedRootQuestion)
            }
        }

        if self.selectedQuestionId == question.id {
            self.selectQuestion(nil)
        }
    }

}

// MARK: - Reverse reusable questions
extension SequenceBuilderViewModel {

    func canReverse(question: Question) -> Bool {
        return findReusableParent(for: question) == nil &&     // check if parent is not reusable question
            self.originalReusableQuestions[question.id] == nil // check if current question is not loaded reusable
    }

    private func getOriginalReusableQuestion(with loadedChilren: Question) -> Question? {
        if  let originalReusableQuestion = self.originalReusableQuestions[loadedChilren.id] {
            return originalReusableQuestion
        }

        if let loadedParent = findReusableParent(for: loadedChilren),
         let originalReusableQuestion = self.originalReusableQuestions[loadedParent.id] {
            return originalReusableQuestion
        }

        return nil
    }

    func reverse(question: Question) {
        guard let reusableQuestion = getOriginalReusableQuestion(with: question)  else {
            return
        }

        for item in self.originalReusableQuestions where item.value.id == reusableQuestion.id {
            if let questionToReplace = getQuestion(with: item.key) {
                replace(question: questionToReplace, with: reusableQuestion)
                selectQuestion(reusableQuestion)
            }
        }
    }

}

// MARK: - Loading reusable questions
extension SequenceBuilderViewModel {

    private func loadReusableQuestion(with filename: String, originalReusable: Question) -> Question? {
        if let reusableQuestion = self.sequencesProvider.loadQuestion(with: filename, from: .local) {
            return reusableQuestion
        } else if let reusableQuestion = self.sequencesProvider.loadQuestion(with: filename, from: .project) {
            return reusableQuestion
        }

        return nil
    }

    func replaceWithReusableQuestion(questionToReplace question: Question) {
        guard case .reusable(let filename) = question.kind,
            let loadedReusableQuestion = loadReusableQuestion(with: filename, originalReusable: question) else {
                return
        }

        let updatedReusableQuestion = Question.prepareReusableQuestion(loadedReusableQuestion)

        // find in a root
        for index in self.questionsSequence.questions.indices {
            if let rootQuestion = self.questionsSequence.questions[safe: index], rootQuestion.id == question.id {
                self.replace(oldQuestion: rootQuestion, with: updatedReusableQuestion)
                self.formLinearArray()
                self.originalReusableQuestions[updatedReusableQuestion.id] = question
                return
            }
        }

        // find in children
        if let rootQuestion = self.questionsSequence.questions.first(where: { self.checkIfChildrenContains(question: question, children: $0.children) }) {
            self.loadReusable(rootQuestion: rootQuestion, reusableQuestion: question, parentQuestion: rootQuestion, loadedReusableQuestion: updatedReusableQuestion)
            self.originalReusableQuestions[updatedReusableQuestion.id] = question
            return
        }

    }

    private func loadReusable(rootQuestion: Question, reusableQuestion: Question, parentQuestion: Question, loadedReusableQuestion: Question) {
        parentQuestion.children.forEach { (childQuestion) in
            if childQuestion.id == reusableQuestion.id {
                var updatedRootQuestion = rootQuestion
                updatedRootQuestion.replace(oldQuestion: childQuestion, newQuestion: loadedReusableQuestion)

                self.replace(oldQuestion: rootQuestion, with: updatedRootQuestion)

                self.syncExpandedQuestions()
                self.formLinearArray()
            } else {
                self.loadReusable(rootQuestion: rootQuestion, reusableQuestion: reusableQuestion, parentQuestion: childQuestion, loadedReusableQuestion: loadedReusableQuestion)
            }
        }
    }

}

// MARK: - Actions
extension SequenceBuilderViewModel {

    func replace(question: Question, with newQuestion: Question) {
        defer {
            self.syncExpandedQuestions()
            self.formLinearArray()

            if let index = self.answers.firstIndex(where: { $0.question.id == question.id }),
                let answer = self.answers[safe: index] {
                let selectedOptions = newQuestion.options.filter { answer.selectedOptions.contains($0) }

                let updatedAnswer = Answer(question: newQuestion, selectedOptions: selectedOptions)
                self.answers.remove(at: index)
                self.answers.insert(updatedAnswer, at: index)
            }
        }

        if self.questionsSequence.questions.contains(question) {
            self.replace(oldQuestion: question, with: newQuestion)
        } else {
            for rootQuestion in self.questionsSequence.questions {
                var copiedRootQuestion = rootQuestion
                copiedRootQuestion.replace(oldQuestion: question, newQuestion: newQuestion)

                self.replace(oldQuestion: rootQuestion, with: copiedRootQuestion)
            }
        }
    }

    func moveQuestion(_ question: Question, at location: InstertLocation) {
        guard question.id != location.question.id else {
            return
        }

        defer {
            self.syncExpandedQuestions()
            self.formLinearArray()
        }

        func insertQestion(in questions: [Question]) -> [Question] {
            var newQuestions: [Question] = []

            for index in questions.indices {
                var currentQuestion = questions[index]
                currentQuestion.children = insertQestion(in: currentQuestion.children)

                switch location {
                case .before(let targetQuestion):
                    if targetQuestion.id == currentQuestion.id {
                        newQuestions.append(question)
                    }
                    newQuestions.append(currentQuestion)
                case .after(let targetQuestion):
                    newQuestions.append(currentQuestion)
                    if targetQuestion.id == currentQuestion.id {
                        newQuestions.append(question)
                    }
                }
            }

            return newQuestions
        }

        self.deleteQuestion(question)
        self.questionsSequence.questions = insertQestion(in: self.questionsSequence.questions)
    }
}

// MARK: - Add/Delete/Insert question
extension SequenceBuilderViewModel {

    func addNewRootQuestion(kind: Question.Kind) -> Question {
        let newQuestion = Question.emptyQuestion(kind: kind)
        self.questionsSequence.questions.append(newQuestion)

        self.syncExpandedQuestions()
        self.formLinearArray()

        return newQuestion
    }

    func changeParent(for question: Question, newParentAt indexPath: IndexPath) {
        guard let parentId = self.visibleQuestionsIds[safe: indexPath.row],
            let parent = getQuestion(with: parentId) else { return }

        self.deleteQuestion(question)
        self.insertChildQuestion(question, to: parent)
    }

    func insertQuestion(_ question: Question, to holderQuestion: Question, with option: InsertOption) {
        switch option {
        case .toSibling:
            _ = insertSiblingQuestion(to: holderQuestion, newQuestion: question)
        case .toChild:
            insertChildQuestion(question, to: holderQuestion)
        }
    }

    func addNewChildQuestion(to question: Question, kind: Question.Kind) -> Question {
        let newQuestion = Question.emptyQuestion(kind: kind)
        self.insertChildQuestion(newQuestion, to: question)

        return newQuestion
    }

    func insertChildQuestion(_ newQuestion: Question, to parent: Question) {
        func appendQuestion(in rootQuestion: Question) {
            var updatedRootQuestion = rootQuestion
            updatedRootQuestion.appendQuestion(with: parent.id, question: newQuestion)

            self.replace(oldQuestion: rootQuestion, with: updatedRootQuestion)

            self.syncExpandedQuestions()
            self.formLinearArray()

        }

        if let rootQuestion = self.questionsSequence.questions.first(where: { $0.id == parent.id }) {
            appendQuestion(in: rootQuestion)
        } else if let rootQuestion = self.questionsSequence.questions.first(where: { self.checkIfChildrenContains(question: parent, children: $0.children) }) {
            appendQuestion(in: rootQuestion)
        }
    }

    func insertSiblingQuestion(to question: Question, newQuestion: Question) -> Bool {
        func syncQuestions() {
            self.syncExpandedQuestions()
            self.formLinearArray()
        }

        if let index = self.questionsSequence.questions.firstIndex(where: { $0.id == question.id }) {
            self.questionsSequence.questions.insert(newQuestion, at: index + 1)

            syncQuestions()
        } else if let rootQuestion = self.questionsSequence.questions.first(where: { self.checkIfChildrenContains(question: question, children: $0.children) }) {
            guard let parentQuestion = self.questionsSequence.findParentQuestion(for: question) else { return false }
            var updatedRootQuestion = rootQuestion
            updatedRootQuestion.appendQuestion(with: parentQuestion.id, question: newQuestion, after: question)

            self.replace(oldQuestion: rootQuestion, with: updatedRootQuestion)

            syncQuestions()
        }

        return true
    }

    func addNewSiblingQuestion(to question: Question, kind: Question.Kind) -> Question? {
        let newQuestion = Question.emptyQuestion(kind: kind)

        let success = insertSiblingQuestion(to: question, newQuestion: newQuestion)

        return success ? newQuestion : nil
    }

    func deleteQuestion(at indexPath: IndexPath) {
        guard let questionId = self.visibleQuestionsIds[safe: indexPath.row],
            let question = getQuestion(with: questionId) else { return }

        self.deleteQuestion(question)
        self.formLinearArray()
    }

    func insert(toQuestion: Question, insertOption: InsertOption, selectedQuestions: [Question]) {
        let questionsToInsert = insertOption == .toSibling ? selectedQuestions.reversed() : selectedQuestions
        for selectedQuestion in questionsToInsert {
            let updatedSelectedQuestion = Question.prepareReusableQuestion(selectedQuestion)
            insertQuestion(updatedSelectedQuestion, to: toQuestion, with: insertOption)
        }
    }
}


// MARK: - Save
extension SequenceBuilderViewModel {

    private func prepareQuestionsSequenceForSave() -> (questionSequence: QuestionsSequence, reusableQuestionsToSave: [String: Question]) {
        var reusableQuestionsToSave: [String: Question] = [:]

        func getQuestions(for questions: [Question]) -> [Question] {
            var newQuestions: [Question] = []

            for index in questions.indices {
                if let question = self.originalReusableQuestions[questions[index].id] {
                    if case .reusable(let filename) = question.kind {
                        reusableQuestionsToSave[filename] = questions[index]
                    }
                    newQuestions.append(question)
                } else {
                    var question = questions[index]
                    question.children = getQuestions(for: question.children)
                    newQuestions.append(question)
                }
            }

            return newQuestions
        }

        var questionSequence = self.questionsSequence
        questionSequence.questions = getQuestions(for: questionSequence.questions)

        return (questionSequence, reusableQuestionsToSave)
    }

    @objc func save() {
        switch self.fileType {
        case .main:
            let dataToSave = prepareQuestionsSequenceForSave()
            self.sequencesProvider.saveObject(object: dataToSave.questionSequence, by: self.questionsSequenceUrl, fileType: self.fileType)
        case .shared:
            let dataToSave = prepareQuestionsSequenceForSave()
            if let question = dataToSave.questionSequence.questions.first {
                self.sequencesProvider.saveObject(object: question, by: self.questionsSequenceUrl, fileType: self.fileType)
            } else {
                self.sequencesProvider.saveObject(object: "", by: self.questionsSequenceUrl, fileType: self.fileType)
            }
        }
    }
}

// MARK: - Getters
extension SequenceBuilderViewModel {

    func getNumberOfQuestions() -> Int {
        return self.visibleQuestionsIds.count
    }

    func getIndexPath(for question: Question) -> IndexPath? {
        guard let row = self.visibleQuestionsIds.firstIndex(where: { $0 == question.id }) else {
            return nil
        }

        return IndexPath(row: row, section: 0)
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

    func getSelectedOptions(for question: Question) -> [Option] {
        guard let answer = self.answers.first(where: { $0.question.id == question.id }) else { return [] }

        return answer.selectedOptions
    }

    func getQuestion(with id: Identifier) -> Question? {
        return self.questionsSequence.findQuestion(with: id)
    }

    func canAddSibling(to question: Question) -> Bool {
        return findReusableParent(for: question) == nil // check if parent is not reusable question
    }

    func canAddChildren(to question: Question) -> Bool {
        switch question.kind {
        case .reusable:
            return false
        default:
            return canEdit(question: question)
        }
    }

    func canEdit(question: Question) -> Bool {
        return findReusableParent(for: question) == nil &&     // check if parent is not reusable question
            self.originalReusableQuestions[question.id] == nil // check if current question is not loaded reusable
    }

    private func findReusableParent(`for` question: Question) -> Question? {
        if let parent = self.questionsSequence.findParentQuestion(for: question) {
            if self.originalReusableQuestions[parent.id] != nil {
                return parent
            }

            return findReusableParent(for: parent)
        }

        return nil
    }
}

// MARK: - Answers
extension SequenceBuilderViewModel {

    func clearAllAnswers() {
        self.answers = []

        self.onUpdate?()
    }

    func clearAnswers(for question: Question) {
        guard let index = self.answers.firstIndex(where: { $0.question.id == question.id }) else { return }

        self.answers.remove(at: index)
        self.onUpdate?()
    }

    func clearAnswersInBranch(for question: Question) {
        self.clearAnswers(for: question)
        self.answers.removeAll(where: { self.checkIfChildrenContains(question: $0.question, children: question.children) })
        self.onUpdate?()
    }

    func updateAnswer(for question: Question, options: [Option]) {
        if !options.isEmpty {
            let updatedAnswer = Answer(question: question, selectedOptions: options)
            if let index = self.answers.firstIndex(where: { $0.question.id == question.id }) {
                self.answers.remove(at: index)
                self.answers.insert(updatedAnswer, at: index)
            } else {
                self.answers.append(updatedAnswer)
            }
        } else {
            self.answers.removeAll(where: { $0.question.id == question.id })
        }
    }

}

// MARK: - Expanding/Collapsing cells
extension SequenceBuilderViewModel {
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

    func expandCollapse(_ question: Question) {
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
