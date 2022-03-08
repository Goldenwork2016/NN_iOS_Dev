//
//  ClientsProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

public final class ClientsProvider {

    let keyValueStorage: KeyValueStorage

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }
    
    public func insertAtBegining(clientIdentifier: ClientIdentifier, job: JobTitle, facility: Facility) {
        let key = getClientsKey(job: job,facility: facility)
        var identifiers = load(key: key)
        identifiers.insert(clientIdentifier, at: 0)
        save(clientIdentifiers: identifiers, key: key)
    }
    
    public func replace(clientIdentifiers: [ClientIdentifier], job: JobTitle, facility: Facility) {
        let key = getClientsKey(job: job,facility: facility)

        save(clientIdentifiers: clientIdentifiers, key: key)
    }
    
    public func load(job: JobTitle, facility: Facility) -> [ClientIdentifier] {
        let key = getClientsKey(job: job,facility: facility)

        return load(key: key)
    }
    
    public func remove(clientIdentifier: ClientIdentifier, job: JobTitle, facility: Facility, unfinishedSequenceProvider: UnfinishedSequencesProvider, noteHistoryProvider: NoteHistoryProvider) {
        // 1 - Remove unfinished sequence and save it in history
        if let unfinishedSequence = unfinishedSequenceProvider.load(facility: facility, job: Preference.jobTitle, clientIdentifier: clientIdentifier) {
            let narrativeGenerator = NarrativeGenerator()
            let narrative = narrativeGenerator.getNarrative(questions: unfinishedSequence.questions, answers: unfinishedSequence.answers)
            let noteHistory = NoteHistory(value: narrative, createdAt: Date(), facility: unfinishedSequence.facility, clientIdentifier: clientIdentifier, jobTitle: Preference.jobTitle, isActive: false)
            noteHistoryProvider.save(note: noteHistory)
            unfinishedSequenceProvider.remove(facility: facility, job: job, clientIdentifier: clientIdentifier)
        }
        
        // 2 - Deactivate all related notes to this client
        noteHistoryProvider.deactivateNotes(facility: facility, clientIdentifier: clientIdentifier, jobTitle: Preference.jobTitle)
        
        // 3 - Remove client from database
        let key = getClientsKey(job: job,facility: facility)
        let identifiers = load(key: key).filter { $0 != clientIdentifier }
        save(clientIdentifiers: identifiers, key: key)
    }
}

extension ClientsProvider {
    
    private func getClientsKey(job: JobTitle, facility: Facility) -> Identifier {
        let intKey = (job.id + facility.id).uniqueHash
        return "clients-\(intKey)"
    }
    
    private func load(key: Identifier) -> [ClientIdentifier] {
        guard let data = self.keyValueStorage.data(forKey: key),
              let identifiers = try? decoder.decode([ClientIdentifier].self, from: data) else {
            return []
        }

        return identifiers
    }
    
    private func save(clientIdentifiers: [ClientIdentifier], key: Identifier) {
        if let data = try? self.encoder.encode(clientIdentifiers) {
            self.keyValueStorage.set(data, forKey: key)
        }
    }
}
