//
//  GlobalSettingKind.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 26.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public enum GlobalSettingKind: String, CaseIterable {

    case replacement = "replacements"
    case pronunciation = "pronunciations"
}

extension GlobalSettingKind {

    private var file: File {
        return .keyValuePair(self)
    }

    private var projectFileUrl: URL {
        let path = Bundle.main.path(forResource: self.file.path, ofType: self.file.type)!
        return URL(fileURLWithPath: path)
    }

    private var localDirectory: URL {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectory
            .appendingPathComponent(Folder.globalSettings.rawValue)
    }

    private var localFileUrl: URL {
        return self.localDirectory
            .appendingPathComponent(self.rawValue)
            .appendingPathExtension(self.file.type ?? "")
    }

    public func save(settings: [GlobalSettingItem]) {
        do {
            try FileManager.default.createDirectory(at: self.localDirectory, withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder().encode(settings)
            try data.write(to: self.localFileUrl)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    public func load() -> [GlobalSettingItem] {
        var data: Data

        do {
            data = try Data(contentsOf: self.projectFileUrl)
        } catch {
            assertionFailure("Can't find settings file in \(self.projectFileUrl.absoluteString)")
            return []
        }

        // Load edit version if exist
        data = (try? Data(contentsOf: self.localFileUrl)) ?? data

        do {
            return try JSONDecoder().decode([GlobalSettingItem].self, from: data)
        } catch {
            assertionFailure("Wrong settings file format of \(self.rawValue)")
            return []
        }
    }
}
