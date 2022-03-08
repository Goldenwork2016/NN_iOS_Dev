//
//  HomeViewModel.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 26.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class HomeViewModel {

    let sequencesProvider: SequencesProvider
    let facilities = Facility.allCases

    init(sequencesProvider: SequencesProvider) {
        self.sequencesProvider = sequencesProvider
    }
    
    func getSequence(for item: Facility) -> QuestionsSequence {
        return self.sequencesProvider.getSequence(for: item, job: Preference.jobTitle)
    }
}
