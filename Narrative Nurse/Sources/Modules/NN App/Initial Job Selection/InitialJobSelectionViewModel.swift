//
//  InitialJobSelectionViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class InitialJobSelectionViewModel {

    let jobs = JobTitle.allCases
    
    func select(job: JobTitle) {
        Preference.jobTitleHasBeenSelected = true
        Preference.jobTitle = job
    }

}
