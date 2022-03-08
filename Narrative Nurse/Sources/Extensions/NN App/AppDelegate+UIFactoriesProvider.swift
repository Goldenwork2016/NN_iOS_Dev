//
//  AppDelegate+UIFactoriesProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

extension AppDelegate {
    
    func createUIFactoryProvider() -> UIFactoriesProvider {
        
        let keyValueStorage = UserDefaults.standard
        let urlHandler = UIApplication.shared
        let sequenceProvider = SequencesProvider()
        let ruleEvaluatorProvider = RuleEvaluatorProvider()
        let questionsProvider = QuestionsProvider(ruleEvaluatorProvider: ruleEvaluatorProvider)
        let unfinishedSequencesProvider = UnfinishedSequencesProvider(keyValueStorage: keyValueStorage)
        let noteHistoryProvider = NoteHistoryProvider(keyValueStorage: keyValueStorage)
        let clientProvider = ClientsProvider(keyValueStorage: keyValueStorage)
        
        let uiFactoriesProvider = UIFactoriesProvider(keyValueStorage: keyValueStorage,
                                                      urlHandler: urlHandler,
                                                      sequencesProvider: sequenceProvider,
                                                      ruleEvaluatorProvider: ruleEvaluatorProvider,
                                                      questionsProvider: questionsProvider, unfinishedSequencesProvider: unfinishedSequencesProvider, noteHistoryProvider: noteHistoryProvider, clientProvider: clientProvider)
        
        return uiFactoriesProvider
    }
    
}
