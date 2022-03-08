//
//  NarrativeGenerator.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 05.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public final class NarrativeGenerator {
    
    private var narrative: String = ""
    private var variablesToOutput: [String: String] = [:]
    
    private let replacements: [GlobalSettingItem] = GlobalSettingKind.replacement.load()
    private let formatters: [SentenceFormatter] = [UppercaseUfterDotSentenceFormatter(),
                                                   SemicolonSentenceFormatter(),
                                                   DuplicationSentenceFormatter()]
    public init() {
    }
    
    public func getNarrative(questions: [Question], answers: [Answer]) -> String {
        self.narrative = ""
        self.variablesToOutput.removeAll()
        
        self.prepareNarrative(questions: questions, answers: answers)
        
        var resultNarrative = self.narrative
        replacements.forEach({ resultNarrative = resultNarrative.replacingOccurrences(of: $0.key, with: $0.value) })
        self.narrative = resultNarrative
        
        self.formatters.forEach { self.narrative = $0.format(sentence: self.narrative) }
        
        return self.narrative
    }
    
    private func prepareNarrative(questions: [Question], answers: [Answer]) {
        for question in questions {
            self.prepareNarrative(question: question, answers: answers)
            
            if let afterChildren = question.narrative?.afterChildren,
                !afterChildren.isEmpty,
                answers.contains(where: { $0.question.id == question.id }) {
                self.appendNarrative(afterChildren)
            }
        }
    }
    
    private func prepareNarrative(question: Question, answers: [Answer]) {
        if case Question.Kind.variablesToOutput(let variables) = question.kind {
            for variable in variables {
                self.appendNarrative(self.variablesToOutput[variable] ?? "")
            }
        } else if let answer = answers.first(where: { $0.question.id == question.id }) {
            if let outputToVariable = question.outputToVariable {
                var questionNarrative = ""
                if let narrativeBefore = answer.question.narrative?.before, let isNone = answer.selectedOptions.first?.kind.isNone, !isNone {
                    if answer.selectedOptions.count > 1, let before = narrativeBefore.plural {
                        questionNarrative = self.appendNarrative(part: before, to: questionNarrative)
                    } else if let before = narrativeBefore.singular {
                        questionNarrative = self.appendNarrative(part: before, to: questionNarrative)
                    }
                }
                
                if case Question.Kind.size = answer.question.kind {
                    let narrative = answer.selectedOptions.compactMap({ $0.narrative }).joined(separator: " ")
                    questionNarrative = self.appendNarrative(part: narrative, to: questionNarrative)
                } else {
                    let narratives = answer.selectedOptions.compactMap { (option) -> String? in
                        if !option.narrative.isEmpty {
                            return option.narrative
                        } else {
                            return nil
                        }
                    }
                    questionNarrative = self.appendNarrative(part: String.compound(items: narratives), to: questionNarrative)
                }
                
                if let narrativeAfter = answer.question.narrative?.after, let isNone = answer.selectedOptions.first?.kind.isNone, !isNone {
                    if answer.selectedOptions.count > 1, let after = narrativeAfter.plural {
                        questionNarrative = self.appendNarrative(part: after, to: questionNarrative)
                    } else if let after = narrativeAfter.singular {
                        questionNarrative = self.appendNarrative(part: after, to: questionNarrative)
                    }
                }
                
                self.variablesToOutput[outputToVariable] = questionNarrative
            } else {
                if let narrativeBefore = answer.question.narrative?.before, let isNone = answer.selectedOptions.first?.kind.isNone, !isNone {
                        if answer.selectedOptions.count > 1, let before = narrativeBefore.plural {
                            self.appendNarrative(before)
                        } else if let before = narrativeBefore.singular {
                            self.appendNarrative(before)
                        }
                    }
                    
                    if case Question.Kind.size = answer.question.kind {
                        let narrative = answer.selectedOptions.compactMap({ $0.narrative }).joined(separator: " ")
                        self.appendNarrative(narrative)
                    } else {
                        let narratives = answer.selectedOptions.compactMap { (option) -> String? in
                            if !option.narrative.isEmpty {
                                return option.narrative
                            } else {
                                return nil
                            }
                        }
                        self.appendNarrative(String.compound(items: narratives))
                    }
                    
                    if let narrativeAfter = answer.question.narrative?.after, let isNone = answer.selectedOptions.first?.kind.isNone, !isNone {
                        if answer.selectedOptions.count > 1, let after = narrativeAfter.plural {
                            self.appendNarrative(after)
                        } else if let after = narrativeAfter.singular {
                            self.appendNarrative(after)
                        }
                    }
                }
            }
        self.prepareNarrative(questions: question.children, answers: answers)
    }
    
    private func appendNarrative(part: String, to narrative: String) -> String {
        var newNarrative = narrative
        if part != "." && part != "," && part != ":" && !part.isEmpty && !narrative.isEmpty {
            newNarrative += " "
        }
        newNarrative += part
        return newNarrative
    }
    
    private func appendNarrative(_ newNarrative: String) {
        if newNarrative != "." && newNarrative != "," && newNarrative != ":" && !newNarrative.isEmpty && !self.narrative.isEmpty {
            self.narrative += " "
        }
        self.narrative += newNarrative
    }
    
}
