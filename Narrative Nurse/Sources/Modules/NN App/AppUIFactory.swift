//
//  AppUIFactory.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AppUIFactory: AppFlowUIFactory {

    let viewModelsFactory: AppViewModelsFactory

    init(viewModelsFactory: AppViewModelsFactory) {
        self.viewModelsFactory = viewModelsFactory
    }

    func makeRootViewController() -> UIViewController {
        // Show launch screen when application loads info about authintification in background
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!

        return viewController
    }

    func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        return navigationController
    }

    func makeHomeViewController() -> HomeViewController {
        let viewModel = self.viewModelsFactory.makeHomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)

        return viewController
    }

    func makeResultViewController(answers: [Answer], questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> ResultViewController {
        let viewModel = self.viewModelsFactory.makeResultViewModel(answers: answers, questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier)
        let viewController = ResultViewController(viewModel: viewModel)

        return viewController
    }

    func makeResultViewController(sentence: NoteHistory) -> ResultViewController {
        let viewModel = self.viewModelsFactory.makeResultViewModel(sentence: sentence)
        let viewController = ResultViewController(viewModel: viewModel)

        return viewController
    }

    func makeNoteHistoryViewController() -> NoteHistoryViewController {
        let viewModel = self.viewModelsFactory.makeNoteHistoryViewModel()
        let viewController = NoteHistoryViewController(viewModel: viewModel)

        return viewController
    }

    func makeSplashViewController() -> SplashViewController {
        let viewModel = self.viewModelsFactory.makeSplashViewModel()
        let viewController = SplashViewController(viewModel: viewModel)

        return viewController
    }

    func makeMenuViewController() -> MenuViewController {
        let viewModel = self.viewModelsFactory.makeMenuViewModel()
        let viewController = MenuViewController(viewModel: viewModel)

        return viewController
    }

    func makeSettingsViewController() -> SettingsViewController {
        let viewModel = self.viewModelsFactory.makeSettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)

        return viewController
    }

    func makeQuestionsViewController(questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> QuestionsViewController {
        let viewModel = self.viewModelsFactory.makeQuestionsViewModel(questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier)
        let viewController = QuestionsViewController(viewModel: viewModel)

        return viewController
    }

    func makeQuestionsViewController(unfinishedSequence: UnfinishedSequence, clientIdentifier: ClientIdentifier) -> QuestionsViewController {
        let viewModel = self.viewModelsFactory.makeQuestionsViewModel(unfinishedSequence: unfinishedSequence, clientIdentifier: clientIdentifier)
        let viewController = QuestionsViewController(viewModel: viewModel)

        return viewController
    }

    func makeNotePreview(narrative: String) -> NotePreviewViewController {
        let notePreviewViewController = NotePreviewViewController(narrative: narrative)

        return notePreviewViewController
    }

    func makeUtiranceSettingsViewController() -> UtiranceSettingsViewController {
        let viewModel = self.viewModelsFactory.makeUtiranceSettingsViewModel()
        let utiranceSettingsViewController = UtiranceSettingsViewController(viewModel: viewModel)

        return utiranceSettingsViewController
    }

    func makeFeedbackViewController() -> FeedbackViewController {
        let viewModel = self.viewModelsFactory.makeFeedbackViewModel()
        let feedbackViewController = FeedbackViewController(viewModel: viewModel)

        return feedbackViewController
    }
    
    func makeRoomsViewController(facility: Facility, questionSequence: QuestionsSequence) -> RoomsViewController {
        let viewModel = self.viewModelsFactory.makeRoomsViewModel(facility: facility, questionSequence: questionSequence)
        let roomsViewController = RoomsViewController(viewModel: viewModel)

        return roomsViewController
    }
    
    func makeEmojiIdentifiersViewController(facility: Facility, questionSequence: QuestionsSequence) -> EmojiIdentifiersViewController {
        let viewModel = self.viewModelsFactory.makeEmojiIdentifiersViewModel(facility: facility, questionSequence: questionSequence)
        let viewController = EmojiIdentifiersViewController(viewModel: viewModel)

        return viewController
    }
    
    func makeClientsViewController(facility: Facility, questionSequence: QuestionsSequence) -> ClientsViewController {
        let viewModel = self.viewModelsFactory.makeClientsViewModel(facility: facility, questionSequence: questionSequence)
        let viewController = ClientsViewController(viewModel: viewModel)

        return viewController
    }
    
    func makeAddRoomViewController(facility: Facility) -> AddRoomViewController {
        let viewModel = self.viewModelsFactory.makeAddRoomViewModel(facility: facility)
        let addRoomViewController = AddRoomViewController(viewModel: viewModel)

        return addRoomViewController
    }
    
    func makeInitialJobSelectionViewController() -> InitialJobSelectionViewController {
        let viewModel = self.viewModelsFactory.makeInitialJobSelectionViewModel()
        let viewController = InitialJobSelectionViewController(viewModel: viewModel)

        return viewController
    }
}
