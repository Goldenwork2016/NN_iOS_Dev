//
//  SettingsViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SettingsViewModel {

    let jobs = JobTitle.allCases

    func select(job: JobTitle) {
        Preference.jobTitle = job
    }

    func isSelected(job: JobTitle) -> Bool {
        return Preference.jobTitle == job
    }

}
