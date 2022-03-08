//
//  CreateNewSequenceViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class GlobalSettingsViewModel {

    let options = GlobalSettingKind.allCases

    func getTitle(for option: GlobalSettingKind) -> String {

        switch option {
        case .replacement:
            return "Find and Replace"
        case .pronunciation:
            return "Custom Pronunciations"
        }

    }

}
