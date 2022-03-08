//
//  SearchQuestionTableViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SearchQuestionTableViewModel {

    struct SearchItem {
        let type: String
        let title: String
        let question: Question
        let path: [Question]
    }

    let questionSequence: QuestionsSequence

    private(set) var items: [SearchItem] = []

    init(questionSequence: QuestionsSequence) {
        self.questionSequence = questionSequence
    }

    func filter(with text: String?) {
        self.items.removeAll()

        guard let text = text?.lowercased(), !text.isEmpty else {
            return
        }

        func filter(option: Option, in question: Question, path: [Question]) {
            if let title = option.kind.title,
                title.lowercased().contains(text) {
                self.items.append(SearchItem(type: "Answer in \"\(question.question)\"", title: title, question: question, path: path))
            }
        }

        func filter(question: Question, path: [Question]) {
            if question.question.lowercased().contains(text) || question.kind.title.lowercased().contains(text) {
                self.items.append(SearchItem(type: "\(question.kind.title) question", title: question.question, question: question, path: path))
            }

            question.options.forEach { filter(option: $0, in: question, path: path) }

            var path = path
            path.append(question)

            question.children.forEach { filter(question: $0, path: path) }
        }

        self.questionSequence.questions.forEach { filter(question: $0, path: []) }
    }
}
