//
//  SequenceBuilderFlowCoordinator.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

protocol SequenceBuilderFlowUIFactory {
    func makeRootViewController() -> UIViewController
    func makeNavigationController(rootViewController: UIViewController) -> UINavigationController
    func makeSequenceViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SequenceBuilderViewController
    func makeSequencesListViewController(infoReprestentation: SequencesListViewModel.InfoReprestentation, source: SequenceSource, fileTypes: [SequenceFileType]) -> SequencesListViewController
    func makeCreateNewSequenceViewController() -> CreateNewSequenceViewController
    func makeSequenceSelectorViewController(subcontrollers: [SequencesListViewController]) -> SequenceSelectorViewController
    func makeSearchQuestionTableViewController(questionSequence: QuestionsSequence) -> SearchQuestionTableViewController
    func makeSaveSequenceViewController(originalUrl: URL?, fileType: SequenceFileType) -> SaveSequenceViewController
    func makeSelectAnswerViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectAnswerViewController
    func makeSelectQuestionsViewController(questionsSequenceUrl: URL, fileType: SequenceFileType) -> SelectQuestionsViewController
    func makeGlobalSettingsViewController() -> GlobalSettingsViewController
    func makeEditGlobalSettingsViewController(kind: GlobalSettingKind) -> EditGlobalSettingsViewController
}

final class SequenceBuilderFlowCoordinator: FlowCoordinator {
    
    let uiFactory: SequenceBuilderFlowUIFactory
    var rootViewController: UIViewController
    var childFlowCoordinators: [FlowCoordinator]
    let ruleEvaluatorProvider: RuleEvaluatorProvider
    
    init(uiFactory: SequenceBuilderFlowUIFactory,
         ruleEvaluatorProvider: RuleEvaluatorProvider) {
        
        self.uiFactory = uiFactory
        self.ruleEvaluatorProvider = ruleEvaluatorProvider
        self.rootViewController = uiFactory.makeRootViewController()
        self.childFlowCoordinators = []
        
        self.rootViewController = self.makeSequencesListViewController()
    }
    
    func install() {
        
    }
    
    private func makeSequencesListViewController() -> UIViewController {
        let viewController = uiFactory.makeSequencesListViewController(infoReprestentation: .all, source: .local, fileTypes: SequenceFileType.allCases)
        viewController.onSequence = { [weak self, weak viewController] (url, fileType) in
            guard let viewController = viewController else { return }
            
            self?.showSequenceViewController(sender: viewController, questionsSequenceUrl: url, fileType: fileType)
        }
        
        viewController.onAdd = { [weak self, weak viewController] in
            guard let viewController = viewController else { return }
            
            self?.showCreateNewSequenceViewController(sender: viewController)
        }
        
        viewController.onGlobalSettings = { [weak self, weak viewController] in
            guard let viewController = viewController else { return }
            
            self?.showGloabalSettingsViewController(sender: viewController, barButtonItem: viewController.navigationItem.leftBarButtonItem)
        }
        
        let navigationController = uiFactory.makeNavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
    private func showSequenceViewController(sender: UIViewController, questionsSequenceUrl: URL, fileType: SequenceFileType) {
        let viewController = uiFactory.makeSequenceViewController(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        viewController.onSearch = { [weak self, weak viewController] (questionSequence, completion) in
            guard let sself = self, let vc = viewController else { return }
            
            sself.showSearchQuestionTableViewController(sender: vc, questionSequence: questionSequence, completion: completion)
        }
        
        viewController.onSelect = { [weak self, weak viewController] (fileType, completion) in
            
            guard let sself = self, let vc = viewController else { return }
            
            sself.showSequencesSelectorViewController(sender: vc, infoReprestentation: .min, fileTypes: [fileType], sources: SequenceSource.allCases, completion: completion)
        }
        
        viewController.onSelectAnswer = { [weak self, weak viewController] (sequence, completion) in
            
            guard let sself = self, let vc = viewController else { return }
            
            sself.showSelectAnswerViewController(from: vc, questionsSequenceUrl: questionsSequenceUrl, fileType: fileType, completion: completion)
        }
        
        viewController.onGlobalSettings = { [weak self, weak viewController] in
            guard let viewController = viewController else { return }
            
            self?.showGloabalSettingsViewController(sender: viewController, barButtonItem: viewController.navigationItem.leftBarButtonItems?.last)
        }
        
        viewController.onSelectQuestions = { [weak self, weak viewController] completion in
            guard let viewController = viewController else { return }
            
            self?.showSequencesSelectorViewController(sender: viewController, infoReprestentation: .min, fileTypes: [.main, .shared], sources: [.local], completion: { (url, filetype) in
                
                self?.showSelectQuestionsViewController(from: viewController, questionsSequenceUrl: url, fileType: filetype, completion: { selectedQuestionIds in
                    completion(url, fileType, selectedQuestionIds)
                })
                
            })
        }
        
        sender.show(viewController, sender: nil)
    }
    
    private func showSearchQuestionTableViewController(sender: UIViewController, questionSequence: QuestionsSequence, completion: @escaping ((SearchQuestionTableViewModel.SearchItem) -> Void)) {
        let searchViewController = self.uiFactory.makeSearchQuestionTableViewController(questionSequence: questionSequence)
        searchViewController.onSelect = completion
        let nc = self.uiFactory.makeNavigationController(rootViewController: searchViewController)
        sender.present(nc, animated: true, completion: nil)
    }
    
    private func showSequencesSelectorViewController(sender: UIViewController, infoReprestentation: SequencesListViewModel.InfoReprestentation, fileTypes: [SequenceFileType], sources: [SequenceSource], completion: @escaping ((URL, SequenceFileType) -> Void)) {
        let viewControllers = sources.map {
            self.uiFactory.makeSequencesListViewController(infoReprestentation: infoReprestentation, source: $0, fileTypes: fileTypes)
        }
        
        let viewController = uiFactory.makeSequenceSelectorViewController(subcontrollers: viewControllers)
        viewController.onSequence = { [weak viewController] (url, fileType) in
            viewController?.dismiss(animated: true, completion: nil)
            completion(url, fileType)
        }
        
        let nc = self.uiFactory.makeNavigationController(rootViewController: viewController)
        
        sender.present(nc, animated: true, completion: nil)
    }
    
    private func showGloabalSettingsViewController(sender: UIViewController, barButtonItem: UIBarButtonItem?) {
        let viewController = uiFactory.makeGlobalSettingsViewController()
        viewController.modalPresentationStyle = .popover
        viewController.onSelect = { [weak self, weak sender] option in
            guard let sender = sender else { return }
            self?.showEditGlobalSettingsViewController(sender: sender, kind: option)
        }
        viewController.popoverPresentationController?.barButtonItem = barButtonItem
        viewController.preferredContentSize = CGSize(width: 250, height: 90)
        
        sender.present(viewController, animated: true, completion: nil)
    }
    
    private func showEditGlobalSettingsViewController(sender: UIViewController, kind: GlobalSettingKind) {
        let editDictionaryViewController = uiFactory.makeEditGlobalSettingsViewController(kind: kind)
        let nc = self.uiFactory.makeNavigationController(rootViewController: editDictionaryViewController)
        
        sender.present(nc, animated: true, completion: nil)
    }
    
    private func showCreateNewSequenceViewController(sender: UIViewController) {
        let viewController = uiFactory.makeCreateNewSequenceViewController()
        viewController.onSelect = { [weak self, weak sender] option in
            guard let sender = sender else { return }
            
            switch option {
            case .newSequence:
                self?.showSaveViewController(sender: sender, originalUrl: nil, fileType: .main)
            case .newReusable:
                self?.showSaveViewController(sender: sender, originalUrl: nil, fileType: .shared)
            case .duplicate:
                self?.showSequencesSelectorViewController(sender: sender, infoReprestentation: .min, fileTypes: SequenceFileType.allCases, sources: SequenceSource.allCases, completion: { [weak self, weak sender] (url, fileType) in
                    guard let sender = sender else { return }
                    
                    self?.showSaveViewController(sender: sender, originalUrl: url, fileType: fileType)
                })
            }
            
        }
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.barButtonItem = sender.navigationItem.rightBarButtonItem
        viewController.preferredContentSize = CGSize(width: 200, height: 135)
        
        sender.present(viewController, animated: true, completion: nil)
    }
    
    private func showSelectAnswerViewController(from sender: UIViewController, questionsSequenceUrl: URL, fileType: SequenceFileType , completion: ((Question, Option) -> Void)?) {
        let vc = self.uiFactory.makeSelectAnswerViewController(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        vc.onSelect = completion
        let nc = self.uiFactory.makeNavigationController(rootViewController: vc)
        sender.present(nc, animated: false, completion: nil)
    }
    
    private func showSelectQuestionsViewController(from sender: UIViewController, questionsSequenceUrl: URL, fileType: SequenceFileType , completion: @escaping (([Question]) -> Void)) {
        let vc = self.uiFactory.makeSelectQuestionsViewController(questionsSequenceUrl: questionsSequenceUrl, fileType: fileType)
        vc.onSelect = completion
        let nc = self.uiFactory.makeNavigationController(rootViewController: vc)
        sender.present(nc, animated: false, completion: nil)
    }
    
    private func showSaveViewController(sender: UIViewController, originalUrl: URL?, fileType: SequenceFileType) {
        let viewController = uiFactory.makeSaveSequenceViewController(originalUrl: originalUrl, fileType: fileType)
        viewController.onSaved = { [weak self] url in
            guard let sself = self else { return }
            
            sself.showSequenceViewController(sender: sender, questionsSequenceUrl: url, fileType: fileType)
        }
        
        viewController.modalPresentationStyle = .overCurrentContext
        
        sender.present(viewController, animated: false, completion: nil)
    }
}
