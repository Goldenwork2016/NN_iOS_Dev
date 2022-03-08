//
//  Analytics.swift
//  Jungle
//
//  Created by Oleh Stasula on 11/10/2019.
//  Copyright © 2019 The Rebl. All rights reserved.
//

import Foundation

final class Analytics {

    private let services: [AnalyticsService]

    init(services: [AnalyticsService]) {
        self.services = services
    }

}

extension Analytics {

    func logEvent(_ named: String, metadata: [String: String]? = nil) {
        self.services.forEach { $0.logEvent(named, metadata: metadata) }
    }

    func setUserProperty(_ named: String, value: String?) {
        self.services.forEach { $0.setUserProperty(named, value: value) }
    }

    func logEvent(_ event: AnalyticsEvent) {
        self.services.forEach { $0.logEvent(event) }
    }
}
