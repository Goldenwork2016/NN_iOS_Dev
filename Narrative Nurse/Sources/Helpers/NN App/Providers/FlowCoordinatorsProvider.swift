//
//  FlowCoordinatorsProvider.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Slavik Voloshyn. All rights reserved.
//

import Foundation
import NNCore

final class FlowCoordinatorsProvider {

    let uiFactoriesProvider: UIFactoriesProvider

    private(set) lazy var appFlowCoordinator: FlowCoordinator = {
        let uiFactory = self.uiFactoriesProvider.makeAppUIFactory()
        let flowCoordinator = AppFlowCoordinator(uiFactory: uiFactory,
                                                 ruleEvaluatorProvider: uiFactoriesProvider.ruleEvaluatorProvider)
        return flowCoordinator
    }()

    init(uiFactoriesProvider: UIFactoriesProvider) {
        self.uiFactoriesProvider = uiFactoriesProvider
    }
}
