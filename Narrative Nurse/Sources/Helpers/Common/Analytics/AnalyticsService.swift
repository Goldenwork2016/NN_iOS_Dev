//
//  AnalyticsService.swift
//  Jungle
//
//  Created by Oleh Stasula on 11/10/2019.
//  Copyright © 2019 The Rebl. All rights reserved.
//

import Foundation

protocol AnalyticsService {
    func logEvent(_ named: String, metadata: [String: String]?)
    func setUserProperty(_ named: String, value: String?)
}

extension AnalyticsService {

    func logEvent(_ event: AnalyticsEvent) {
        self.logEvent(event.name, metadata: event.metadada)
    }

}
