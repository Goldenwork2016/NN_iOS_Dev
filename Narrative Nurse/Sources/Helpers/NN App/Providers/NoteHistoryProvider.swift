//
//  NoteHistoryProvider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

public final class NoteHistoryProvider {

    let keyValueStorage: KeyValueStorage
    
    private let key = "note-history"
    private let decoder = PropertyListDecoder()
    private let encoder = PropertyListEncoder()

    public init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    public func save(note: NoteHistory) {
        var history = load()
        history.append(note)
        if let data = try? self.encoder.encode(history) {
            self.keyValueStorage.set(data, forKey: self.key)
        }
    }
    
    public func load() -> [NoteHistory] {
        guard let data = self.keyValueStorage.data(forKey: self.key),
              let decodedHistory = try? self.decoder.decode([NoteHistory].self, from: data) else {
            return []
        }
        
        return decodedHistory
    }
    
    public func deactivateNotes(facility: Facility, clientIdentifier: ClientIdentifier, jobTitle: JobTitle) {
        let updatedNotes: [NoteHistory] = self.load()
            .map {
            if $0.facility == facility && $0.clientIdentifier == clientIdentifier && $0.jobTitle == jobTitle {
                return NoteHistory(value: $0.value, createdAt: $0.createdAt, facility: $0.facility, clientIdentifier: $0.clientIdentifier, jobTitle: $0.jobTitle, isActive: false)
            } else {
                return $0
            }
        }
        
        if let data = try? self.encoder.encode(updatedNotes) {
            self.keyValueStorage.set(data, forKey: self.key)
        }
    }
}
