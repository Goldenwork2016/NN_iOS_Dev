//
//  File.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 27.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

private let rootDataFolder = "Data"

public enum Folder: String {
    case images = "Images"
    case shared = "Shared"
    case sequences = "Sequences"
    case globalSettings = "Global Settings"

    public var path: String {
        return "\(rootDataFolder)/\(self.rawValue)"
    }
}

public enum File {
    case sequence(JobTitle, Facility)
    case image(String)
    case question(String)
    case introAnimation
    case keyValuePair(GlobalSettingKind)
}

// MARK: - Path

extension File {

    public var path: String {
        switch self {
        case .sequence(let job, let facility):
            return "\(Folder.sequences.path)/\(facility.id)_\(job.id)"
        case .image(let filename):
            return "\(Folder.images.path)/\(filename)"
        case .question(let filename):
            return "\(Folder.shared.path)/\(filename)"
        case .introAnimation:
            return "Animations/intro"
        case .keyValuePair(let kind):
            return "\(Folder.globalSettings.path)/\(kind.rawValue)"
        }
    }

    public var type: String? {
        switch self {
        case .sequence, .question, .keyValuePair:
            return "json"
        case .introAnimation:
            return "mp4"
        case .image:
            return nil
        }
    }

}
