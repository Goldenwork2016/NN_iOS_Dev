//
//  RoomsViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class RoomsViewModel {
    
    let facility: Facility
    let questionSequence: QuestionsSequence
    let clientsProvider: ClientsProvider
    let unfinishedSequenceProvider: UnfinishedSequencesProvider
    let noteHistoryProvider: NoteHistoryProvider
    
    private(set) var rooms: [Int: [RoomSection]] = [:]
    
    init(facility: Facility, questionSequence: QuestionsSequence, clientsProvider: ClientsProvider, unfinishedSequenceProvider: UnfinishedSequencesProvider, noteHistoryProvider: NoteHistoryProvider) {
        self.facility = facility
        self.questionSequence = questionSequence
        self.clientsProvider = clientsProvider
        self.unfinishedSequenceProvider = unfinishedSequenceProvider
        self.noteHistoryProvider = noteHistoryProvider
        
        updateRooms()
    }
    
    func updateRooms() {
        self.rooms.removeAll()
        for client in self.clientsProvider.load(job: Preference.jobTitle, facility: self.facility) {
            if case .room(let number, let section) = client {
                var sections = self.rooms[number] ?? []
                sections.append(section)
                self.rooms[number] = sections
            }
        }
    }
    
    func getRoomNumber(at index: Int) -> Int? {
        return Array(self.rooms.keys).sorted()[safe: index]
    }
    
    func deleteRoom(at index: Int) {
        guard let roomNumber = getRoomNumber(at: index),
              let roomSections = self.rooms[roomNumber] else {
            return
        }
        
        roomSections.forEach {
            self.clientsProvider.remove(clientIdentifier: .room(number: roomNumber, section: $0), job: Preference.jobTitle, facility: self.facility, unfinishedSequenceProvider: self.unfinishedSequenceProvider, noteHistoryProvider: self.noteHistoryProvider)
        }
        
        updateRooms()
    }
}
