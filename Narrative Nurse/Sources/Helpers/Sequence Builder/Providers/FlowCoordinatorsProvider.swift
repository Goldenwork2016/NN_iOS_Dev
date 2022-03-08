//
//  FlowCoordinatorsProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class FlowCoordinatorsProvider {

    let uiFactoriesProvider: UIFactoriesProvider

    private(set) lazy var appFlowCoordinator: FlowCoordinator = {
        let uiFactory = self.uiFactoriesProvider.makeAppUIFactory()
        let flowCoordinator = SequenceBuilderFlowCoordinator(uiFactory: uiFactory,
                                                 ruleEvaluatorProvider: uiFactoriesProvider.ruleEvaluatorProvider)
        return flowCoordinator
    }()

    init(uiFactoriesProvider: UIFactoriesProvider) {
        self.uiFactoriesProvider = uiFactoriesProvider
    }
}
