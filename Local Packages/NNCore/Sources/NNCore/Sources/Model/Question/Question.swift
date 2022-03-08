//
//  Question.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 27.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public struct Question: Codable {

    enum Keys: String, CodingKey {
        case id
        case question
        case imagePath
        case region
        case multiselection
        case options
        case rule
        case children
        case outputToVariable
    }

    public let id: Identifier
    public let question: String
    public let narrative: Narrative?
    public let outputToVariable: String?
    public let kind: Kind
    public let options: [Option]
    public let rule: String

    public var children: [Question]

    public init(id: Identifier, question: String, narrative: Narrative?, outputToVariable: String?, kind: Question.Kind, options: [Option], rule: String, children: [Question]) {
        self.id = id
        self.question = question
        self.narrative = narrative
        self.outputToVariable = outputToVariable
        self.kind = kind
        self.options = options
        self.rule = rule
        self.children = children
    }
}

// MARK: - Equatable
extension Question: Equatable {

    public static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id && lhs.kind == rhs.kind && lhs.narrative == rhs.narrative && lhs.outputToVariable == rhs.outputToVariable && lhs.question == rhs.question && lhs.rule == rhs.rule && lhs.options == rhs.options
    }

}

// MARK: - Mutating children
public extension Question {

    mutating func appendQuestion(with parentId: Identifier, question: Question) {
        if self.id == parentId {
            self.children.append(question)
        } else {
            for index in self.children.indices {
                self.children[index].appendQuestion(with: parentId, question: question)
            }
        }
    }

    mutating func replace(oldQuestion: Question, newQuestion: Question) {
        if let index = self.children.firstIndex(of: oldQuestion) {
            self.children.remove(at: index)
            self.children.insert(newQuestion, at: index)
        } else {
            for index in self.children.indices {
                self.children[index].replace(oldQuestion: oldQuestion, newQuestion: newQuestion)
            }
        }
    }

    mutating func appendQuestion(with parentId: Identifier, question: Question, after: Question?) {
        if self.id == parentId {
            if let after = after, let index = self.children.firstIndex(where: { $0.id == after.id }) {
                self.children.insert(question, at: index + 1)
            } else {
                self.children.insert(question, at: 0)
            }
        } else {
            for index in self.children.indices {
                self.children[index].appendQuestion(with: parentId, question: question, after: after)
            }
        }
    }

    mutating func removeQuestion(with id: Identifier) {
        if self.children.contains(where: { $0.id == id }) {
            self.children.removeAll(where: { $0.id == id })
        } else {
            for index in self.children.indices {
                self.children[index].removeQuestion(with: id)
            }
        }
    }

}
