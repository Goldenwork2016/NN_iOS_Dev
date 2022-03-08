//
//  Sentence.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 02.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

public struct NoteHistory: Codable, Hashable {

    public let value: String
    public let createdAt: Date
    public let facility: Facility
    public let clientIdentifier: ClientIdentifier
    public let jobTitle: JobTitle
    public let isActive: Bool
}
