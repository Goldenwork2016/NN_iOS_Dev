//
//  FirebaseAnalyticsService.swift
//  Jungle
//
//  Created by Oleh Stasula on 11/10/2019.
//  Copyright © 2019 The Rebl. All rights reserved.
//

import FirebaseAnalytics
import Foundation

final class FirebaseAnalyticsService {
}

extension FirebaseAnalyticsService: AnalyticsService {

    func logEvent(_ named: String, metadata: [String: String]?) {
        FirebaseAnalytics.Analytics.logEvent(named.snakeCased.withMaxLenght(40), parameters: metadata?.snakeCasedAndObjected)
    }

    func setUserProperty(_ named: String, value: String?) {
        FirebaseAnalytics.Analytics.setUserProperty(value?.snakeCased.withMaxLenght(36), forName: named.snakeCased.withMaxLenght(24))
    }

}

extension String {

    fileprivate func withMaxLenght(_ maxCharacters: Int) -> String {
        return String(self.prefix(maxCharacters))
    }

    fileprivate var snakeCased: String {
        return self.lowercased().replacingOccurrences(of: " ", with: "_", options: String.CompareOptions.caseInsensitive, range: nil)
    }
}

extension Dictionary where Key == String, Value == String {

    fileprivate var snakeCasedAndObjected: [String: NSObject] {
        var dict = [String: NSObject]()
        self.forEach {
            dict[$0.key.snakeCased.withMaxLenght(40)] = $0.value.snakeCased.withMaxLenght(100) as NSObject
        }
        return dict
    }
}
