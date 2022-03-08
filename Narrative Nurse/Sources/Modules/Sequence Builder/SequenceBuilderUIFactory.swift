//
//  SequenceBuilderUIFactory.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class SequenceBuilderUIFactory: SequenceBuilderFlowUIFactory {

    let viewModelsFactory: SequenceBuilderViewModelsFactory

    init(viewModelsFactory: SequenceBuilderViewModelsFactory) {
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

    func makeSequenceViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SequenceBuilderViewController {
        let viewModel = self.viewModelsFactory.makeSequenceViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        let viewController = SequenceBuilderViewController(viewModel: viewModel)

        return viewController
    }

    func makeSequencesListViewController(infoReprestentation: SequencesListViewModel.InfoReprestentation, source: SequenceSource, fileTypes: [SequenceFileType]) -> SequencesListViewController {
        let viewModel = self.viewModelsFactory.makeSequencesListViewModel(infoReprestentation: infoReprestentation, source: source, fileTypes: fileTypes)
        let viewController = SequencesListViewController(viewModel: viewModel)

        return viewController
    }

    func makeCreateNewSequenceViewController() -> CreateNewSequenceViewController {
        let viewModel = self.viewModelsFactory.makeCreateNewSequenceViewModel()
        let viewController = CreateNewSequenceViewController(viewModel: viewModel)

        return viewController
    }

    func makeSequenceSelectorViewController(subcontrollers: [SequencesListViewController]) -> SequenceSelectorViewController {
        let viewModel = self.viewModelsFactory.makeSequenceSelectorViewModel()
        let viewController = SequenceSelectorViewController(viewModel: viewModel, subcontrollers: subcontrollers)

        return viewController
    }

    func makeSearchQuestionTableViewController(questionSequence: QuestionsSequence) -> SearchQuestionTableViewController {
        let viewModel = self.viewModelsFactory.makeSearchQuestionTableViewModel(questionSequence: questionSequence)
        let viewController = SearchQuestionTableViewController(viewModel: viewModel)

        return viewController
    }

    func makeSaveSequenceViewController(originalUrl: URL?, fileType: SequenceFileType) -> SaveSequenceViewController {
        let viewModel = self.viewModelsFactory.makeSaveSequenceViewModel(originalUrl: originalUrl, fileType: fileType)
        let viewController = SaveSequenceViewController(viewModel: viewModel)

        return viewController
    }

    func makeSelectAnswerViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectAnswerViewController {
        let viewModel = self.viewModelsFactory.makeSelectAnswerViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        let viewController = SelectAnswerViewController(viewModel: viewModel)

        return viewController
    }

    func makeGlobalSettingsViewController() -> GlobalSettingsViewController {
         let viewModel = self.viewModelsFactory.makeGlobalSettingsViewModel()
         let viewController = GlobalSettingsViewController(viewModel: viewModel)

         return viewController
    }

    func makeEditGlobalSettingsViewController(kind: GlobalSettingKind) -> EditGlobalSettingsViewController {
        let viewModel = self.viewModelsFactory.makeEditGlobalSettingsViewModel(kind: kind)
         let viewController = EditGlobalSettingsViewController(viewModel: viewModel)

         return viewController
    }

    func makeSelectQuestionsViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectQuestionsViewController {
        let viewModel = self.viewModelsFactory.makeSelectQuestionsViewModel(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        let viewController = SelectQuestionsViewController(selectQuestionsViewModel: viewModel)

        return viewController
    }
}
