//
//  ClientsViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class ClientsViewModel {
    
    let facility: Facility
    let questionSequence: QuestionsSequence
    let unfinishedSequenceProvider: UnfinishedSequencesProvider
    let noteHistoryProvider: NoteHistoryProvider
    let clientsProvider: ClientsProvider

    private(set) var clientIdentifiers: [ClientIdentifier] = []
    private(set) var noteHistory: [NoteHistory] = []
    
    init(facility: Facility, questionSequence: QuestionsSequence, unfinishedSequenceProvider: UnfinishedSequencesProvider, clientsProvider: ClientsProvider, noteHistoryProvider: NoteHistoryProvider) {
        self.facility = facility
        self.questionSequence = questionSequence
        self.unfinishedSequenceProvider = unfinishedSequenceProvider
        self.clientsProvider = clientsProvider
        self.noteHistoryProvider = noteHistoryProvider
        
        reloadData()
    }
    
    func reloadData() {
        self.clientIdentifiers.removeAll()
        for clientIdentifier in self.clientsProvider.load(job: Preference.jobTitle, facility: self.facility) {
            switch self.facility {
            case .homeHealth:
                if case .emoji = clientIdentifier {
                    self.clientIdentifiers.append(clientIdentifier)
                }
            case .skilled, .assistedLiving:
                if case .room = clientIdentifier {
                    self.clientIdentifiers.append(clientIdentifier)
                }
            }
        }
        
        self.noteHistory = self.noteHistoryProvider.load()
    }
    
    func getUnfinishedSequence(for clientIdentifier: ClientIdentifier) -> UnfinishedSequence? {
        return self.unfinishedSequenceProvider.load(facility: self.facility, job: Preference.jobTitle, clientIdentifier: clientIdentifier)
    }
    
    func getLastNoteHistory(for clientIdentifier: ClientIdentifier) -> NoteHistory? {
        self.noteHistory.filter { $0.jobTitle == Preference.jobTitle &&
            $0.clientIdentifier == clientIdentifier &&
            $0.facility == self.facility &&
            $0.isActive }
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
    }
    
    func deleteAllClients() {
        self.clientIdentifiers
            .forEach { self.delete(client: $0) }
    }
    
    func delete(client: ClientIdentifier) {
        self.clientsProvider.remove(clientIdentifier: client, job: Preference.jobTitle, facility: self.facility, unfinishedSequenceProvider: self.unfinishedSequenceProvider, noteHistoryProvider: self.noteHistoryProvider)
        
        reloadData()
    }
    
    func getNarrative(for unfinishedSequence: UnfinishedSequence) -> String {
        let narrativeGenerator = NarrativeGenerator()
        return narrativeGenerator.getNarrative(questions: unfinishedSequence.questions, answers: unfinishedSequence.answers)
    }
    
    func moveClient(from: Int, to: Int) {
        guard let client = self.clientIdentifiers[safe: from] else { return }

        self.clientIdentifiers.remove(at: from)
        self.clientIdentifiers.insert(client, at: to)
        
        self.clientsProvider.replace(clientIdentifiers: self.clientIdentifiers, job: Preference.jobTitle, facility: self.facility)
    }

}
