//
//  SequenceBuilderUIFactoriesProvider.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class UIFactoriesProvider {

    let keyValueStorage: KeyValueStorage
    let urlHandler: URLHandler
    let sequencesProvider: SequencesProvider
    let ruleEvaluatorProvider: RuleEvaluatorProvider
    let questionsProvider: QuestionsProvider

    init(keyValueStorage: KeyValueStorage,
         urlHandler: URLHandler,
         sequencesProvider: SequencesProvider,
         ruleEvaluatorProvider: RuleEvaluatorProvider,
         questionsProvider: QuestionsProvider) {
        self.keyValueStorage = keyValueStorage
        self.urlHandler = urlHandler
        self.sequencesProvider = sequencesProvider
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
        self.questionsProvider = questionsProvider
    }

    func makeAppUIFactory() -> SequenceBuilderUIFactory {
        let viewModelsFactory = SequenceBuilderViewModelsFactory(sequncesProvider: self.sequencesProvider, keyValueStorage: self.keyValueStorage, ruleEvaluatorProvider: self.ruleEvaluatorProvider, questionsProvider: self.questionsProvider)
        let uiFactory = SequenceBuilderUIFactory(viewModelsFactory: viewModelsFactory)
        return uiFactory
    }

}
