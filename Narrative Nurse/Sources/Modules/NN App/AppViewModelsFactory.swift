//
//  AppViewModelsFactory.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 26.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class AppViewModelsFactory {

    let sequncesProvider: SequencesProvider
    let keyValueStorage: KeyValueStorage
    let ruleEvaluatorProvider: RuleEvaluatorProvider
    let questionsProvider: QuestionsProvider
    let unfinishedSequencesProvider: UnfinishedSequencesProvider
    let noteHistoryProvider: NoteHistoryProvider
    let clientsProvider: ClientsProvider
    
    init(sequncesProvider: SequencesProvider, keyValueStorage: KeyValueStorage, ruleEvaluatorProvider: RuleEvaluatorProvider, questionsProvider: QuestionsProvider, unfinishedSequencesProvider: UnfinishedSequencesProvider, noteHistoryProvider: NoteHistoryProvider, clientsProvider: ClientsProvider) {
        self.sequncesProvider = sequncesProvider
        self.keyValueStorage = keyValueStorage
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
        self.questionsProvider = questionsProvider
        self.unfinishedSequencesProvider = unfinishedSequencesProvider
        self.noteHistoryProvider = noteHistoryProvider
        self.clientsProvider = clientsProvider
    }

    func makeHomeViewModel() -> HomeViewModel {
        let viewModel = HomeViewModel(sequencesProvider: self.sequncesProvider)

        return viewModel
    }

    func makeResultViewModel(answers: [Answer], questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> ResultViewModel {
        let viewModel = ResultViewModel(answers: answers, questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier, noteHistoryProvider: self.noteHistoryProvider)

        return viewModel
    }

    func makeResultViewModel(sentence: NoteHistory) -> ResultViewModel {
        let viewModel = ResultViewModel(sentence: sentence)

        return viewModel
    }

    func makeNoteHistoryViewModel() -> NoteHistoryViewModel {
        let viewModel = NoteHistoryViewModel(noteHistoryProvider: self.noteHistoryProvider)

        return viewModel
    }

    func makeSplashViewModel() -> SplashViewModel {
        let viewModel = SplashViewModel()

        return viewModel
    }

    func makeMenuViewModel() -> MenuViewModel {
        let viewModel = MenuViewModel(sequencesProvider: self.sequncesProvider)

        return viewModel
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        let viewModel = SettingsViewModel()

        return viewModel
    }

    func makeQuestionsViewModel(questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> QuestionsViewModel {
        let viewModel = QuestionsViewModel(questionsProvider: self.questionsProvider, sequencesProvider: self.sequncesProvider, unfinishedSequencesProvider: self.unfinishedSequencesProvider, questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier)
        return viewModel
    }

    func makeQuestionsViewModel(unfinishedSequence: UnfinishedSequence, clientIdentifier: ClientIdentifier) -> QuestionsViewModel {
        let viewModel = QuestionsViewModel(questionsProvider: self.questionsProvider, sequencesProvider: self.sequncesProvider, unfinishedSequencesProvider: self.unfinishedSequencesProvider, unfinishedSequence: unfinishedSequence, clientIdentifier: clientIdentifier)
        return viewModel
    }

    func makeUtiranceSettingsViewModel() -> UtiranceSettingsViewModel {
        let veiwModel = UtiranceSettingsViewModel()

        return veiwModel
    }

    func makeFeedbackViewModel() -> FeedbackViewModel {
        let feedbackSender = FeedbackSender()
        let viewModel = FeedbackViewModel(feedbackSender: feedbackSender)

        return viewModel
    }
    
    func makeRoomsViewModel(facility: Facility, questionSequence: QuestionsSequence) -> RoomsViewModel {
        let viewModel = RoomsViewModel(facility: facility, questionSequence: questionSequence, clientsProvider: self.clientsProvider, unfinishedSequenceProvider: self.unfinishedSequencesProvider, noteHistoryProvider: self.noteHistoryProvider)

        return viewModel
    }
    
    func makeEmojiIdentifiersViewModel(facility: Facility, questionSequence: QuestionsSequence) -> EmojiIdentifiersViewModel {
        let viewModel = EmojiIdentifiersViewModel(facility: facility, questionSequence: questionSequence, cliensProvider: self.clientsProvider)

        return viewModel
    }
    
    func makeClientsViewModel(facility: Facility, questionSequence: QuestionsSequence) -> ClientsViewModel {
        let viewModel = ClientsViewModel(facility: facility, questionSequence: questionSequence, unfinishedSequenceProvider: self.unfinishedSequencesProvider, clientsProvider: self.clientsProvider, noteHistoryProvider: self.noteHistoryProvider)

        return viewModel
    }
    
    func makeAddRoomViewModel(facility: Facility) -> AddRoomViewModel {
        let viewModel = AddRoomViewModel(facility: facility, clientsProvider: self.clientsProvider)

        return viewModel
    }
    
    func makeInitialJobSelectionViewModel() -> InitialJobSelectionViewModel {
        let viewModel = InitialJobSelectionViewModel()

        return viewModel
    }
}
