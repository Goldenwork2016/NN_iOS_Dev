//
//  File.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 28.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import Appodeal
import Firebase
import FirebaseCore
import UIKit
import NNCore

extension AppDelegate {

    func setupServices() {
        //setupAppodeal()
        setupFirebase()
    }

    private func setupAppodeal() {
        let adTypes: AppodealAdType = [.interstitial, .banner, .nativeAd]
        Appodeal.setTestingEnabled(Environment.isDebug)
        Appodeal.setTriggerPrecacheCallbacks(true)
        Appodeal.setLogLevel(.warning)
        Appodeal.setAutocache(true, types: adTypes)

        Appodeal.initialize(withApiKey: "23ee212c791b8275146ccf2150fb48e69f582a7b3e8057de", types: adTypes)
    }

    private func setupFirebase() {
        FirebaseApp.configure()
    }
}
