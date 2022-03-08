//
//  CreateNewSequenceViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 16.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

final class CreateNewSequenceViewModel {

    enum Kind: String, CaseIterable {
        case newSequence = "New Sequence"
        case newReusable = "New Reusable"
        case duplicate = "Duplicate"
    }

    let options = Kind.allCases

}
