//
//  ListViewModel.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 02.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class NoteHistoryViewModel {

    let noteHistoryProvider: NoteHistoryProvider
    private let sentences: [NoteHistory]

    private var groupedSentences: [String: [NoteHistory]] = [:]
    private var keys: [String] = []

    init(noteHistoryProvider: NoteHistoryProvider) {
        self.noteHistoryProvider = noteHistoryProvider
        self.sentences = noteHistoryProvider.load()
        
        self.groupAndSortSentences()
    }

    private func groupAndSortSentences() {
        self.groupedSentences = self.sentences.categorize({ $0.createdAt.stringValue() })
        self.keys = Array(self.groupedSentences.keys).sorted(by: { $0.dateValue() > $1.dateValue() })

        for (key, values) in self.groupedSentences {
            self.groupedSentences[key] = values.sorted(by: { $0.createdAt > $1.createdAt })
        }
    }
}

// MARK: - Getters
extension NoteHistoryViewModel {
    func getNumberOfSections() -> Int {
        return self.keys.count
    }

    func getNumberOfItems(in section: Int) -> Int {
        guard let key = self.getKey(for: section) else { return 0 }
        return self.groupedSentences[key]?.count ?? 0
    }

    func getKey(for section: Int) -> String? {
        return self.keys[safe: section]
    }

    func getNoteHistory(for indexPath: IndexPath) -> NoteHistory? {
        guard let key = self.getKey(for: indexPath.section), let values = self.groupedSentences[key] else { return nil }

        return values[safe: indexPath.row]
    }

    func getSentence(at index: Int) -> NoteHistory? {
        return self.sentences[safe: index]
    }
}

fileprivate extension Sequence {
    func categorize<U: Hashable>(_ key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U: [Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

fileprivate extension Date {

    func stringValue() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        let dateString = dateFormatter.string(from: self)

        return dateString
    }
}

fileprivate extension String {

    func dateValue() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        let date = dateFormatter.date(from: self) ?? Date()

        return date
    }
}
