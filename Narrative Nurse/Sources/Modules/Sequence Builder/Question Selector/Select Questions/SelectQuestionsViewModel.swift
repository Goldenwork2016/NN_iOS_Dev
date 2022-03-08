//
//  SelectQuestionsViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SelectQuestionsViewModel: BaseQuestionSelectorViewModel {

    var selectedQuestions: [Question] {
        return self.questionsSequence.questions.flatMap { remap(question: $0    ) }
    }

    private var selectedQuestionsIds: [Identifier] = []

    func isQuestionSelected(_ question: Question) -> Bool {
        return self.selectedQuestionsIds.contains(question.id)
    }

    func switchSelectonState(for question: Question) {
        if isQuestionSelected(question) {
            self.selectedQuestionsIds.removeAll(where: { $0 == question.id })
        } else {
            self.selectedQuestionsIds.append(question.id)
        }
    }

    private func remap(question: Question) -> [Question] {
        if isQuestionSelected(question) {
            var modifiedQuestion = question
            modifiedQuestion.children = question.children.flatMap { self.remap(question: $0) }

            return [modifiedQuestion]
        } else {
            return question.children.flatMap { self.remap(question: $0) }
        }
    }

}
