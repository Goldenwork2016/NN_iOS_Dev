//
//  AnalyticsItem.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 27.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

protocol AnalyticsEvent {
    var name: String { get }
    var metadada: [String: String]? { get }
}
