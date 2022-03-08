//
//  MenuViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class MenuViewModel {

    let menu = MenuItem.allCases
    let sequencesProvider: SequencesProvider

    init(sequencesProvider: SequencesProvider) {
        self.sequencesProvider = sequencesProvider
    }

}
