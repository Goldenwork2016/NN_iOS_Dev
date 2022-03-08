//
//  FlowCoordinator.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public protocol FlowCoordinator: class {
    var rootViewController: UIViewController { get }
    var childFlowCoordinators: [FlowCoordinator] { get set }
    func install()
}

public extension FlowCoordinator {

    func addChildFlowCoordinator(_ childFlowCoordinator: FlowCoordinator) {
        guard !self.childFlowCoordinators.contains(where: { $0 === childFlowCoordinator }) else { return }
        self.childFlowCoordinators.append(childFlowCoordinator)
        childFlowCoordinator.install()
    }

    func removeChildFlowCoordinator(_ childFlowCoordinator: FlowCoordinator) {
        self.childFlowCoordinators = self.childFlowCoordinators.filter { $0 !== childFlowCoordinator }
    }
}
