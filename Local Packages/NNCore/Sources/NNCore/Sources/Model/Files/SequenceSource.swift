//
//  SequenceSource.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum SequenceSource: CaseIterable {

    case local
    case project

    public var title: String {
        switch self {
        case .project:
            return "Project"
        case .local:
            return "Local"
        }
    }

}
