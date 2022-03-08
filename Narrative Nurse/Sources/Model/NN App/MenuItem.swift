//
//  Menu.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

enum MenuItem: CaseIterable {
    case about
    case terms
    case feedback
    case settings
    case history
}

extension MenuItem {

    var title: String {
        switch self {
        case .history:
            return "Note History"
        case .about:
            return "About Narrative Nurse"
        case .terms:
            return "Terms of use"
        case .settings:
            return "Settings"
        case .feedback:
            return "Send Feedback"
        }
    }

    var image: UIImage {
        switch self {
        case .history:
            return Assets.history.image
        case .about:
            return Assets.info.image
        case .terms:
            return Assets.security.image
        case .settings:
            return Assets.settings.image
        case .feedback:
            return Assets.email.image
        }
    }
}
