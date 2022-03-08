//
//  AddRoomViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class AddRoomViewModel {
    
    let roomSections = RoomSection.allCases
    let facility: Facility
    let clientsProvider: ClientsProvider
    
    private(set) var roomNumber = ""
    private var selectedRoomSections = Set<RoomSection>()
    
    init(facility: Facility, clientsProvider: ClientsProvider) {
        self.facility = facility
        self.clientsProvider = clientsProvider
    }
    
    var isValidRoomNumber: Bool {
        return !self.roomNumber.isEmpty
            && Int(self.roomNumber) != nil
            && !selectedRoomSections.isEmpty
    }
    
    var selectedRoomSectionsString: String {
        return Array(self.selectedRoomSections)
            .map { $0.title }
            .sorted(by: { $0 < $1 })
            .joined(separator: " ")
    }
    
    func addRoomNumber(_ value: Int) {
        guard self.roomNumber.count < 5 else {
            return
        }
        
        self.roomNumber.append(String(value))
    }
    
    func clear() {
        self.roomNumber = ""
        self.selectedRoomSections.removeAll()
    }
    
    func isRoomSectionSelected(at index: Int) -> Bool {
        guard let roomSection = self.roomSections[safe: index] else {
            return false
        }
        
        return self.selectedRoomSections.contains(roomSection)
    }
    
    func toogleRoomSections(at index: Int) {
        guard let roomSection = self.roomSections[safe: index] else {
            return
        }
        
        if isRoomSectionSelected(at: index) {
            self.selectedRoomSections.remove(roomSection)
        } else {
            self.selectedRoomSections.insert(roomSection)
        }
    }
    
    func save() {
        guard self.isValidRoomNumber,
              let roomNumber = Int(self.roomNumber) else {
            assertionFailure("Cannot convert room number")
            return
        }
        
        Array(self.selectedRoomSections)
            .sorted(by: { $0.title < $1.title })
            .map { ClientIdentifier.room(number: roomNumber, section: $0) }
            .forEach { item in
                if !self.clientsProvider.load(job: Preference.jobTitle, facility: self.facility).contains(item) {
                    self.clientsProvider.insertAtBegining(clientIdentifier: item, job: Preference.jobTitle, facility: self.facility)
                }
            }
    }
}
