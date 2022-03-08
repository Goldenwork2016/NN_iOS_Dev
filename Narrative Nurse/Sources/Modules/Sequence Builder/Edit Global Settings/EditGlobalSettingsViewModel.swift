//
//  FindAndReplaceViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class EditGlobalSettingsViewModel {

    let kind: GlobalSettingKind
    private var values: [GlobalSettingItem]

    var title: String {
        switch self.kind {
        case .replacement:
            return "Find and Replace"
        case .pronunciation:
            return "Custom Pronunciation"
        }
    }

    var keyTitle: String {
        return "Phrase"
    }

    var valueTitle: String {
        switch self.kind {
        case .replacement:
            return "Replace With"
        case .pronunciation:
            return "Pronunciation"
        }
    }

    init(kind: GlobalSettingKind) {
        self.kind = kind
        self.values = kind.load()
    }

    var countElements: Int {
        return self.values.count
    }

    func getSettingItem(at index: IndexPath) -> GlobalSettingItem {
        return self.values[index.row]
    }

    func update(at index: IndexPath, key: String, value: String) {
        self.values[index.row] = GlobalSettingItem(key: key, value: value)
    }

    func addNew() {
        self.values.append(GlobalSettingItem(key: "", value: ""))
    }

    func save() {
        self.kind.save(settings: self.values)
    }

    func delete(at index: IndexPath) {
        self.values.remove(at: index.row)
    }
}
