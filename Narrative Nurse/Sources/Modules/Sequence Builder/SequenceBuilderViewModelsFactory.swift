//
//  SequenceBuilderViewModelsFactory.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SequenceBuilderViewModelsFactory {

    let sequncesProvider: SequencesProvider
    let keyValueStorage: KeyValueStorage
    let ruleEvaluatorProvider: RuleEvaluatorProvider
    let questionsProvider: QuestionsProvider

    init(sequncesProvider: SequencesProvider, keyValueStorage: KeyValueStorage, ruleEvaluatorProvider: RuleEvaluatorProvider, questionsProvider: QuestionsProvider) {
        self.sequncesProvider = sequncesProvider
        self.keyValueStorage = keyValueStorage
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
        self.questionsProvider = questionsProvider
    }

    func makeSequenceViewModel(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SequenceBuilderViewModel {
        let viewModel = SequenceBuilderViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType, sequencesProvider: self.sequncesProvider)
        return viewModel
    }

    func makeSequencesListViewModel(infoReprestentation: SequencesListViewModel.InfoReprestentation, source: SequenceSource, fileTypes: [SequenceFileType]) -> SequencesListViewModel {
        let viewModel = SequencesListViewModel(infoReprestentation: infoReprestentation, source: source, sequencesProvider: self.sequncesProvider, fileTypes: fileTypes)

        return viewModel
    }

    func makeCreateNewSequenceViewModel() -> CreateNewSequenceViewModel {
        let viewModel = CreateNewSequenceViewModel()

        return viewModel
    }

    func makeSequenceSelectorViewModel() -> SequenceSelectorViewModel {
        let viewModel = SequenceSelectorViewModel()

        return viewModel
    }

    func makeSearchQuestionTableViewModel(questionSequence: QuestionsSequence) -> SearchQuestionTableViewModel {
        let viewModel = SearchQuestionTableViewModel(questionSequence: questionSequence)

        return viewModel
    }

    func makeSaveSequenceViewModel(originalUrl: URL?, fileType: SequenceFileType) -> SaveSequenceViewModel {
        let viewModel = SaveSequenceViewModel(sequencesProvider: self.sequncesProvider, originalUrl: originalUrl, fileType: fileType)

        return viewModel
    }

    func makeSelectAnswerViewModel(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectAnswerViewModel {
        let viewModel = SelectAnswerViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType, sequencesProvider: self.sequncesProvider)

        return viewModel
    }

    func makeGlobalSettingsViewModel() -> GlobalSettingsViewModel {
        let viewModel = GlobalSettingsViewModel()

        return viewModel
    }

    func makeEditGlobalSettingsViewModel(kind: GlobalSettingKind) -> EditGlobalSettingsViewModel {
        let viewModel = EditGlobalSettingsViewModel(kind: kind)

        return viewModel
    }

    func makeSelectQuestionsViewModel(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectQuestionsViewModel {
        let viewModel = SelectQuestionsViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType, sequencesProvider: self.sequncesProvider)

        return viewModel
    }
}
