//
//  SelectEmojiViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 14.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class EmojiIdentifiersViewModel {
    
    let facility: Facility
    let questionSequence: QuestionsSequence
    let cliensProvider: ClientsProvider
    
    var showAllEmojies = false
    
    private let allEmojies = Emoji.nn_patientEmojies
    private var savedEmojies: [Emoji] = []
    private var tempSelectedEmojies: [Emoji] = []
    
    init(facility: Facility, questionSequence: QuestionsSequence, cliensProvider: ClientsProvider) {
        self.facility = facility
        self.questionSequence = questionSequence
        self.cliensProvider = cliensProvider
        
        loadSelectedEmojies()
    }
    
    func loadSelectedEmojies() {
        let loadedClientIdentifiers = self.cliensProvider.load(job: Preference.jobTitle, facility: self.facility)
        
        self.savedEmojies = Emoji.nn_patientEmojies.filter { possibleEmoji in
            return loadedClientIdentifiers.contains(where: { clientIdentifiers in
                if case .emoji(emoji: let emoji) = clientIdentifiers  {
                   return possibleEmoji == emoji
                } else {
                    return false
                }
            })
        }
    }
    
    func saveSelectedEmojie() {
        self.tempSelectedEmojies
            .filter { !savedEmojies.contains($0) }
            .forEach { self.cliensProvider.insertAtBegining(clientIdentifier: .emoji(emoji: $0), job: Preference.jobTitle, facility: self.facility) }
        self.tempSelectedEmojies.removeAll()
        loadSelectedEmojies()
    }
    
}

// MARK: - Data
extension EmojiIdentifiersViewModel {
    
    private var activeEmojies: [Emoji] {
        if self.showAllEmojies {
            return self.allEmojies
        } else {
            var emojies: [Emoji] = [Emoji.nn_patientEmojies[0], Emoji.nn_patientEmojies[1]] // Adding extra emojies "male" and "female" at the begining
            self.savedEmojies
                .filter { !emojies.contains($0) }
                .forEach { emojies.append($0) }
            return emojies
        }
    }
    
    var noSelectedIdentiers: Bool {
        return self.tempSelectedEmojies.isEmpty && self.savedEmojies.isEmpty
    }
    
    var countOfEmojies: Int {
        return self.activeEmojies.count
    }
    
    func isSelected(at index: Int) -> Bool {
        guard let emojie = getEmojie(at: index) else {
            return false
        }
        
        return self.savedEmojies.contains(emojie) || self.tempSelectedEmojies.contains(emojie)
    }
    
    func getEmojie(at index: Int) -> Emoji? {
        return self.activeEmojies[safe: index]
    }
    
    func switchSelectedState(at index: Int) {
        guard let emojie = getEmojie(at: index) else {
            return
        }
        
        if self.tempSelectedEmojies.contains(emojie) {
            self.tempSelectedEmojies.removeAll(where: { $0 == emojie })
        } else {
            self.tempSelectedEmojies.append(emojie)
        }
    }
    
}
