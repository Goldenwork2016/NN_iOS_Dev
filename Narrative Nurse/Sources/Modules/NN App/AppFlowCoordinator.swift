//
//  AppFlowCoordinator.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

protocol AppFlowUIFactory {
    func makeRootViewController() -> UIViewController
    func makeNavigationController(rootViewController: UIViewController) -> UINavigationController
    func makeHomeViewController() -> HomeViewController
    func makeResultViewController(answers: [Answer], questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> ResultViewController
    func makeResultViewController(sentence: NoteHistory) -> ResultViewController
    func makeNoteHistoryViewController() -> NoteHistoryViewController
    func makeSplashViewController() -> SplashViewController
    func makeMenuViewController() -> MenuViewController
    func makeSettingsViewController() -> SettingsViewController
    func makeQuestionsViewController(questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier) -> QuestionsViewController
    func makeQuestionsViewController(unfinishedSequence: UnfinishedSequence, clientIdentifier: ClientIdentifier) -> QuestionsViewController
    func makeNotePreview(narrative: String) -> NotePreviewViewController
    func makeUtiranceSettingsViewController() -> UtiranceSettingsViewController
    func makeFeedbackViewController() -> FeedbackViewController
    func makeRoomsViewController(facility: Facility, questionSequence: QuestionsSequence) -> RoomsViewController
    func makeEmojiIdentifiersViewController(facility: Facility, questionSequence: QuestionsSequence) -> EmojiIdentifiersViewController
    func makeAddRoomViewController(facility: Facility) -> AddRoomViewController
    func makeClientsViewController(facility: Facility, questionSequence: QuestionsSequence) -> ClientsViewController
    func makeInitialJobSelectionViewController() -> InitialJobSelectionViewController
}

final class AppFlowCoordinator: FlowCoordinator {

    let uiFactory: AppFlowUIFactory
    var rootViewController: UIViewController
    var childFlowCoordinators: [FlowCoordinator]
    let ruleEvaluatorProvider: RuleEvaluatorProvider

    init(uiFactory: AppFlowUIFactory,
         ruleEvaluatorProvider: RuleEvaluatorProvider) {

        self.uiFactory = uiFactory
        self.ruleEvaluatorProvider = ruleEvaluatorProvider

        self.rootViewController = uiFactory.makeRootViewController()
        self.childFlowCoordinators = []
        
        self.rootViewController = self.makeSplashViewController()
    }

    func install() {

    }

    private func makeSplashViewController() -> UIViewController {
        let splashViewController = uiFactory.makeSplashViewController()
        let navigationController = uiFactory.makeNavigationController(rootViewController: splashViewController)

        splashViewController.onAnimationFinished = { [weak self, weak splashViewController] in
            guard let sself = self, let vc = splashViewController else { return }
            
            if Preference.jobTitleHasBeenSelected {
                sself.showHomeViewController(from: vc)
            } else {
                sself.showInitialJobSelectionController(from: vc)
            }
            
        }

        return navigationController
    }
    
    private func showInitialJobSelectionController(from sender: UIViewController) {
        let initialJobSelectionViewController = self.uiFactory.makeInitialJobSelectionViewController()
        initialJobSelectionViewController.onSelected = { [weak self, weak initialJobSelectionViewController] in
            guard let sself = self, let vc = initialJobSelectionViewController else { return }
            
            sself.showHomeViewController(from: vc)
        }
        sender.show(initialJobSelectionViewController, sender: nil)
    }
    
    private func showResultViewController(answers: [Answer], questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier, from sender: UIViewController) {
        let viewController = self.uiFactory.makeResultViewController(answers: answers, questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier)
        showResultViewController(resultViewController: viewController, from: sender)
    }

    private func showResultViewController(sentence: NoteHistory, from sender: UIViewController) {
        let viewController = self.uiFactory.makeResultViewController(sentence: sentence)
        showResultViewController(resultViewController: viewController, from: sender)
    }

    private func showResultViewController(resultViewController: ResultViewController, from sender: UIViewController) {
        resultViewController.onUtiranceSettings = { [weak resultViewController, weak self] in
            guard let sself = self, let vc = resultViewController else { return }
            sself.showUtiranceSettingsViewController(from: vc)
        }
        resultViewController.onFeedback = { [weak self, weak resultViewController] in
            guard let sself = self, let vc = resultViewController else { return }

            sself.showSendFeedbackViewController(from: vc)
        }
        sender.show(resultViewController, sender: nil)
    }

    private func showQuestions(questionsSequence: QuestionsSequence, facility: Facility, clientIdentifier: ClientIdentifier, from sender: UIViewController) {
        guard questionsSequence.questions.count > 0 else { return }

        let viewController = self.uiFactory.makeQuestionsViewController(questions: questionsSequence.questions, categoryItem: facility, clientIdentifier: clientIdentifier)

        showQuestions(questionsViewController: viewController, categoryItem: facility, clientIdentifier: clientIdentifier, sender: sender)
    }

    private func showQuestions(unfinishedSequence: UnfinishedSequence, clientIdentifier: ClientIdentifier, from sender: UIViewController) {
        let viewController = self.uiFactory.makeQuestionsViewController(unfinishedSequence: unfinishedSequence, clientIdentifier: clientIdentifier)
        showQuestions(questionsViewController: viewController, categoryItem: unfinishedSequence.facility, clientIdentifier: clientIdentifier, sender: sender)
    }

    private func showQuestions(questionsViewController: QuestionsViewController, categoryItem: Facility, clientIdentifier: ClientIdentifier, sender: UIViewController) {
        questionsViewController.onComplete = { [weak self, weak questionsViewController] questions, answers in
            guard let sself = self, let vc = questionsViewController else { return }
            sself.showResultViewController(answers: answers, questions: questions, categoryItem: categoryItem, clientIdentifier: clientIdentifier, from: vc)
        }
        questionsViewController.onNotePreview = { [weak self, weak questionsViewController] narrative in
            guard let sself = self, let vc = questionsViewController else { return }

            sself.presentNotePreview(narrative: narrative, from: vc)
        }
        questionsViewController.onFeedback = { [weak self, weak questionsViewController] in
            guard let sself = self, let vc = questionsViewController else { return }

            sself.showSendFeedbackViewController(from: vc)
        }

        let navigationController = self.uiFactory.makeNavigationController(rootViewController: questionsViewController)
        navigationController.isNavigationBarHidden = false
        navigationController.modalPresentationStyle = .fullScreen
        sender.show(navigationController, sender: nil)
    }

    private func presentNotePreview(narrative: String, from sender: UIViewController) {
        let vc = self.uiFactory.makeNotePreview(narrative: narrative)

        sender.present(vc, animated: true, completion: nil)
    }

    private func showListViewController(from sender: UIViewController) {
        let viewController = self.uiFactory.makeNoteHistoryViewController()
        viewController.onResult = { [weak self, weak viewController] sentence in
            guard let sself = self, let vc = viewController else { return }
            sself.showResultViewController(sentence: sentence, from: vc)
        }
        sender.show(viewController, sender: nil)
    }

    private func showHomeViewController(from sender: UIViewController) {
        let homeViewController = uiFactory.makeHomeViewController()

        homeViewController.onQuestions = { [weak self, weak homeViewController] questionsSequence, facility in
            guard let sself = self, let vc = homeViewController  else { return }
            
            switch facility {
            case .skilled, .assistedLiving:
                sself.showRoomsViewController(facility: facility, questionSequence: questionsSequence, from: vc)
            case .homeHealth:
                sself.showEmojieIdentifiersViewController(facility: facility, questionSequence: questionsSequence, from: vc)
            }
        }

        homeViewController.onMenu = { [weak self, weak homeViewController] in
            guard let sself = self, let vc = homeViewController else { return }

            sself.showMenu(from: vc)
        }

        sender.show(homeViewController, sender: nil)
    }

    private func showUtiranceSettingsViewController(from sender: UIViewController) {
        let vc = self.uiFactory.makeUtiranceSettingsViewController()

        sender.present(vc, animated: true, completion: nil)
    }

    private func showMenu(from sender: UIViewController) {
        let menuViewController = uiFactory.makeMenuViewController()
        menuViewController.onMenuItem = { [weak self, weak sender] item in
            guard let sself = self, let vc = sender else { return }

            switch item {
            case .history:
                sself.showListViewController(from: vc)
            case .about, .terms:
                if let url = URL(string: "https://www.google.com") {
                    UIApplication.shared.open(url)
                }
            case .settings:
                sself.showSettingsViewController(from: vc)
            case .feedback:
                sself.showSendFeedbackViewController(from: vc)
            }
        }

        let nc = UINavigationController(rootViewController: menuViewController)
        nc.modalPresentationStyle = .overCurrentContext
        sender.present(nc, animated: false, completion: nil)
    }

    private func showSendFeedbackViewController(from sender: UIViewController) {
        let vc = self.uiFactory.makeFeedbackViewController()
        sender.present(vc, animated: true, completion: nil)
    }

    private func showSettingsViewController(from sender: UIViewController) {
        let settingsViewController = uiFactory.makeSettingsViewController()
        sender.show(settingsViewController, sender: nil)
    }
    
    private func showRoomsViewController(facility: Facility, questionSequence: QuestionsSequence, from sender: UIViewController) {
        let roomsViewController = uiFactory.makeRoomsViewController(facility: facility, questionSequence: questionSequence)
        roomsViewController.onAdd = { [weak self, weak roomsViewController] completion in
            guard let sself = self, let vc = roomsViewController else { return }
            sself.showAddRoomViewController(facility: facility, completion: completion, from: vc)
        }
        roomsViewController.onNext = { [weak self, weak roomsViewController] in
            guard let sself = self, let vc = roomsViewController else { return }
            
            sself.showClientViewController(facility: facility, questionSequence: questionSequence, from: vc)
        }
        sender.show(roomsViewController, sender: nil)
    }
    
    private func showEmojieIdentifiersViewController(facility: Facility, questionSequence: QuestionsSequence, from sender: UIViewController) {
        let emojiesViewController = uiFactory.makeEmojiIdentifiersViewController(facility: facility, questionSequence: questionSequence)
        emojiesViewController.onNext = { [weak self, weak emojiesViewController] in
            guard let sself = self, let vc = emojiesViewController else { return }
            
            sself.showClientViewController(facility: facility, questionSequence: questionSequence, from: vc)
        }
        sender.show(emojiesViewController, sender: nil)
    }
    
    private func showClientViewController(facility: Facility, questionSequence: QuestionsSequence, from sender: UIViewController) {
        let clientsViewController = uiFactory.makeClientsViewController(facility: facility, questionSequence: questionSequence)
        clientsViewController.onStart = { [weak self, weak clientsViewController] clientIdentifier in
            guard let sself = self, let vc = clientsViewController else { return }
            
            sself.showQuestions(questionsSequence: questionSequence, facility: facility, clientIdentifier: clientIdentifier, from: vc)
        }
        
        clientsViewController.onContinue = { [weak self, weak clientsViewController] clientIdentifier, unfinishedSequence in
            guard let sself = self, let vc = clientsViewController else { return }
            
            sself.showQuestions(unfinishedSequence: unfinishedSequence, clientIdentifier: clientIdentifier, from: vc)
        }
        
        clientsViewController.onPreview = { [weak self, weak clientsViewController] narrative in
            guard let sself = self, let vc = clientsViewController else { return }
            
            sself.presentNotePreview(narrative: narrative, from: vc)
        }
        
        sender.show(clientsViewController, sender: nil)
    }
    
    private func showAddRoomViewController(facility: Facility, completion: @escaping BoolClosure, from sender: UIViewController) {
        let vc = self.uiFactory.makeAddRoomViewController(facility: facility)
        vc.onConfirm = completion
        sender.present(vc, animated: true, completion: nil)
    }
}
