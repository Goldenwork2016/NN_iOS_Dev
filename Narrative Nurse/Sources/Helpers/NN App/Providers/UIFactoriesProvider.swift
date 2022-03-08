//
//  UIFactoriesProvider.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Slavik Voloshyn. All rights reserved.
//

import Foundation
import NNCore

final class UIFactoriesProvider {

    let keyValueStorage: KeyValueStorage
    let urlHandler: URLHandler
    let sequencesProvider: SequencesProvider
    let ruleEvaluatorProvider: RuleEvaluatorProvider
    let questionsProvider: QuestionsProvider
    let unfinishedSequencesProvider: UnfinishedSequencesProvider
    let noteHistoryProvider: NoteHistoryProvider
    let clientProvider: ClientsProvider
    
    init(keyValueStorage: KeyValueStorage,
         urlHandler: URLHandler,
         sequencesProvider: SequencesProvider,
         ruleEvaluatorProvider: RuleEvaluatorProvider,
         questionsProvider: QuestionsProvider,
         unfinishedSequencesProvider: UnfinishedSequencesProvider,
         noteHistoryProvider: NoteHistoryProvider,
         clientProvider: ClientsProvider) {
        self.keyValueStorage = keyValueStorage
        self.urlHandler = urlHandler
        self.sequencesProvider = sequencesProvider
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
        self.questionsProvider = questionsProvider
        self.unfinishedSequencesProvider = unfinishedSequencesProvider
        self.noteHistoryProvider = noteHistoryProvider
        self.clientProvider = clientProvider
    }

    // MARK: - App
    func makeAppUIFactory() -> AppUIFactory {
        let viewModelsFactory = AppViewModelsFactory(sequncesProvider: self.sequencesProvider, keyValueStorage: self.keyValueStorage, ruleEvaluatorProvider: self.ruleEvaluatorProvider, questionsProvider: self.questionsProvider, unfinishedSequencesProvider: self.unfinishedSequencesProvider, noteHistoryProvider: self.noteHistoryProvider, clientsProvider: self.clientProvider)
        let uiFactory = AppUIFactory(viewModelsFactory: viewModelsFactory)
        return uiFactory
    }

}
