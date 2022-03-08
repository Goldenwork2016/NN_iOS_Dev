//
//  AppDelegate.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appFlowCoordinator: FlowCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.setupServices()
        self.setupAppearance()

        let uiFactoriesProvider = createUIFactoryProvider()
        let flowCoordinatorsProvider = FlowCoordinatorsProvider(uiFactoriesProvider: uiFactoriesProvider)
        let appFlowCoordinator = flowCoordinatorsProvider.appFlowCoordinator
        appFlowCoordinator.install()
        self.appFlowCoordinator = appFlowCoordinator

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = appFlowCoordinator.rootViewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
