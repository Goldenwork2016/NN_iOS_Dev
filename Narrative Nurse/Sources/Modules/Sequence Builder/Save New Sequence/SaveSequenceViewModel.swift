//
//  SaveSequenceViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 18.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SaveSequenceViewModel {

    let sequencesProvider: SequencesProvider
    let originalUrl: URL?
    let fileType: SequenceFileType

    init(sequencesProvider: SequencesProvider, originalUrl: URL?, fileType: SequenceFileType) {
        self.sequencesProvider = sequencesProvider
        self.originalUrl = originalUrl
        self.fileType = fileType
    }

    func save(with name: String) -> URL? {
        guard !name.isEmpty else {
            assertionFailure()
            return nil
        }

        if let originalUrl = self.originalUrl {
            switch self.fileType {
            case .main:
                if let questionsSequence: QuestionsSequence = self.sequencesProvider.loadObject(by: originalUrl) {
                    return self.sequencesProvider.saveObject(object: questionsSequence, with: name, fileType: self.fileType)
                }
            case .shared:
                if let question: Question = self.sequencesProvider.loadObject(by: originalUrl) {
                    return self.sequencesProvider.saveObject(object: question, with: name, fileType: self.fileType)
                }
            }
        } else {
            switch self.fileType {
            case .main:
                return self.sequencesProvider.saveObject(object: QuestionsSequence.empty, with: name, fileType: self.fileType)
            case .shared:
                return self.sequencesProvider.saveObject(object: "", with: name, fileType: self.fileType)
            }
        }

        return nil
    }

}
