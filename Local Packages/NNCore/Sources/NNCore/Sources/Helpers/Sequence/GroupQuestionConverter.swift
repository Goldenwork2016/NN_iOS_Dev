//
//  GoupQuestionConverter.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 06.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public final class GroupQuestionConverter {
    
    public let question: Question
    public var hasSelectedOptions: Bool {
        return !self.sselectedOptions.isEmpty
    }
    
    private var selectedOptions: [Option: Option?] = [:]
    private var sselectedOptions: [Option] {
        var options: [Option] = []
        for (_, value) in self.selectedOptions {
            if let option = value {
                options.append(option)
            }
        }
        return options
    }
    private var order: QroupQuestionOrder {
        guard case .grouped(_, let order) = self.question.kind  else {
            return .questionAnswer
        }
        
        return order
    }
    
    public init(question: Question) {
        self.question = question
    }
    
    public func getSelectedOption(for option: Option) -> Option? {
        return self.selectedOptions[option] ?? nil
    }
    
    public func removeSelectedOption(for option: Option) {
        self.selectedOptions.removeValue(forKey: option)
    }
    
    public func clearAnswers() {
        self.selectedOptions.removeAll()
    }
    
    public func optionSelected(parentOption: Option, childOption: Option) {
        guard let rootOption = self.question.options.first(where: { $0.kind.children.contains(parentOption) })
            else { return }
        
        if childOption.kind.isNone {
            rootOption.kind.children.forEach { (option) in
                self.selectedOptions[option] = nil
            }
        } else {
            var children: [Option] = []
            rootOption.kind.children.forEach { (option) in
                children.append(contentsOf: option.kind.children)
            }
            
            children.filter { $0.kind.isNone }
                .forEach { (option) in
                self.selectedOptions.forEach { (key, value) in
                    if value == option {
                        self.selectedOptions[key] = nil
                    }
                }
            }
        }
        
        self.selectedOptions[parentOption] = childOption
    }
    
    public func nextButtonPressed() -> Option? {
        guard self.sselectedOptions.count > 0 else { return nil }
        
        var narrative = self.question.options.compactMap { getNarrative(for: $0) }
            .filter { !$0.isEmpty }
            .joined(separator: ";")
        
        while narrative.prefix(1) == " " {
            narrative = String(narrative.dropFirst())
        }
        
        guard let oldOption = self.question.options.first else { return nil }
        
        let option = Option(kind: oldOption.kind, narrative: narrative, id: oldOption.id)
        
        return option
    }
    
    private func getNarrative(for rootOption: Option) -> String? {
        guard case Option.Kind.grouped = rootOption.kind else { return nil }
        
        var optionNarrative: String = ""
        
        optionNarrative += rootOption.narrative
        
        let selectedOptions: [Option: Option?] = self.selectedOptions.filter({ key, value in rootOption.kind.children.contains(key) && value != nil })
        
        var selectedAnswers: [Option: [Option]] = [:]

        for (option, answer) in selectedOptions {
            if let answer = answer {
                selectedAnswers[answer] = (selectedAnswers[answer] ?? []) + [option]
            }
        }
        
        var index = 0
        for (key, values) in selectedAnswers {
            if let option = values.first, case Option.Kind.groupedOverride(_, _) = option.kind, !key.narrative.isEmpty {
                optionNarrative += " " + key.narrative
            } else {
                let valuesString = String.compound(items: values.compactMap({ $0.narrative }))
                let linkingVerb = getLinkingVerb(for: values)
                let groupBefore = getGroupBefore(for: values, in: rootOption.kind)
                let groupAfter = getGroupAfter(for: values, in: rootOption.kind)
                switch self.order {
                case .questionAnswer:
                    optionNarrative += " \(groupBefore) \(valuesString) \(groupAfter) \(linkingVerb) \(key.narrative)"
                case .answerQuestion:
                    optionNarrative += " \(groupBefore) \(key.narrative) \(linkingVerb) \(valuesString) \(groupAfter)"
                }
            }
            index += 1
            if index != selectedAnswers.keys.count && selectedAnswers.keys.count != 1 {
                optionNarrative += ","
            }
        }
        
//        if rootOption != question.options.last {
//            optionNarrative += narrativeAfter
//        }
        
        return optionNarrative
    }
}

// MARK: - Irregular form
extension GroupQuestionConverter {
    
    private func getLinkingVerb(for options: [Option]) -> String {
        guard case .grouped(let linkingVerb, _) = self.question.kind  else {
            return String()
        }
        
        return getString(from: linkingVerb, for: options)
    }
    
    private func getGroupBefore(for options: [Option], in kind: Option.Kind) -> String {
        guard case .grouped(_, beforeGroup: let beforeGroup, _, _, _) = kind else {
            return String()
        }
        
        return getString(from: beforeGroup, for: options)
    }
    
    private func getGroupAfter(for options: [Option], in kind: Option.Kind) -> String {
        guard case .grouped(_, _, afterGroup: let afterGroup, _, _) = kind else {
            return String()
        }
        
        return getString(from: afterGroup, for: options)
    }
    
    private func getString(from irregularForm: IrregularForm, for options: [Option]) -> String {
        
        let verb = options.count > 1 ? irregularForm.plural : irregularForm.singular
        
        return verb ?? String()
    }
}
