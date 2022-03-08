//
//  UnfinishedSequencesProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 06.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

public final class UnfinishedSequencesProvider {

    let keyValueStorage: KeyValueStorage

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    public func save(unfinishedSequence: UnfinishedSequence, job: JobTitle, clientIdentifier: ClientIdentifier) {
        let key = getUnfinishedSequenceKey(facility: unfinishedSequence.facility, job: job, clientIdentifier: clientIdentifier)
        if let data = try? self.encoder.encode(unfinishedSequence) {
            self.keyValueStorage.set(data, forKey: key)
        }
    }

    public func load(facility: Facility, job: JobTitle, clientIdentifier: ClientIdentifier) -> UnfinishedSequence? {
        let key = getUnfinishedSequenceKey(facility: facility, job: job, clientIdentifier: clientIdentifier)
        
        guard let data = self.keyValueStorage.data(forKey: key) else {
            return nil
        }

        return try? decoder.decode(UnfinishedSequence.self, from: data)
    }

    public func remove(facility: Facility, job: JobTitle, clientIdentifier: ClientIdentifier) {
        let key = getUnfinishedSequenceKey(facility: facility, job: job, clientIdentifier: clientIdentifier)
        self.keyValueStorage.set(nil, forKey: key)
    }
    
    private func getUnfinishedSequenceKey(facility: Facility, job: JobTitle, clientIdentifier: ClientIdentifier) -> String {
        let intKey = (facility.id + clientIdentifier.id + job.id).uniqueHash
        return "unfinished-sequence-\(intKey)"
    }
}
