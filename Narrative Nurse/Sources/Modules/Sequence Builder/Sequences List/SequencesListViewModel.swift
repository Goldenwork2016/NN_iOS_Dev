//
//  SequencesListViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 16.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SequencesListViewModel {

    enum InfoReprestentation {
        case all
        case min
    }

    let infoReprestentation: InfoReprestentation
    let source: SequenceSource
    let sequencesProvider: SequencesProvider
    let fileTypes: [SequenceFileType]

    private var paths: [String: [String]] = [:]

    init(infoReprestentation: InfoReprestentation, source: SequenceSource, sequencesProvider: SequencesProvider, fileTypes: [SequenceFileType]) {
        self.infoReprestentation = infoReprestentation
        self.source = source
        self.sequencesProvider = sequencesProvider
        self.fileTypes = fileTypes

        update()
    }

    func getCountSections() -> Int {
        return self.paths.keys.count
    }

    func getSectionTitle(at section: Int) -> String {
        return Array(self.paths.keys.sorted(by: { $0 < $1 }))[safe: section] ?? ""
    }

    func getItems(in section: Int) -> [String] {
        let sectionTitle = getSectionTitle(at: section)
        return self.paths[sectionTitle] ?? []
    }

    func getTitle(at indexPath: IndexPath) -> String {
        guard let item = getItems(in: indexPath.section)[safe: indexPath.row] else {
            return ""
        }

        return pathToTitle(path: item)
    }

    func delete(at indexPath: IndexPath) -> Bool {
        guard let url = getUrl(at: indexPath) else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: url)
            update()
            return true
        } catch {
            return false
        }
    }

    func getDetails(at indexPath: IndexPath) -> String? {
        guard self.infoReprestentation == .all,
            self.source == .local,
            let url = getUrl(at: indexPath) else {
                return nil
        }

        var details: [String] = []

        let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .medium

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)

            if let sequenceFileType = url.sequenceFileType {
                details.append("Type \(sequenceFileType.title)")
            }

            if let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
                details.append("Edited \(formater.string(from: modificationDate))")
            }

            if let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                details.append("Created \(formater.string(from: creationDate))")
            }

        } catch {
            return nil
        }

        return details.joined(separator: " • ")
    }

    func getUrl(at indexPath: IndexPath) -> URL? {
        guard let item = getItems(in: indexPath.section)[safe: indexPath.row] else {
            return nil
        }

        switch self.source {
        case .project:
            return URL(fileURLWithPath: item)
        case .local:
            return URL(string: item)
        }
    }

    func getFileType(at indexPath: IndexPath) -> SequenceFileType? {
        guard let url = getUrl(at: indexPath) else {
            return nil
        }

        switch self.source {
        case .project:
            if let _: QuestionsSequence = self.sequencesProvider.loadObject(by: url) {
                return .main
            } else if let _: Question = self.sequencesProvider.loadObject(by: url) {
                return .shared
            }

            return nil
        case .local:
            return url.sequenceFileType
        }
    }
}

// MARK: - Loading
extension SequencesListViewModel {

    func update() {
        self.paths.removeAll()
        self.fileTypes.forEach {
            switch self.source {
            case .project:
                switch $0 {
                case .main:
                    addPathsFromResources(folder: .sequences)
                case .shared:
                    addPathsFromResources(folder: .shared)
                }
            case .local:
                addPathsFromRecent(for: $0)
            }
        }
    }

    private func addPathsFromRecent(for fileType: SequenceFileType) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            var fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs.sort {
                pathToTitle(path: $0.absoluteString) < pathToTitle(path: $1.absoluteString)
            }

            for url in fileURLs where fileType == url.sequenceFileType {
                var array = self.paths[fileType.title] ?? []
                array.append(url.absoluteString)
                self.paths[fileType.title] = array
            }

        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }

    private func addPathsFromResources(folder: Folder) {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: folder.path)
        if !paths.isEmpty {
            self.paths[folder.rawValue] = paths.sorted()
        }
    }

    private func getLastModificationDate(url: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
            let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
            return modificationDate
        }

        return Date()
    }

    private func getLastModificationDateString(url: URL) -> String {
        let formater = DateFormatter()
        formater.dateStyle = .medium

        let date = getLastModificationDate(url: url)
        return formater.string(from: date)
    }

    private func pathToTitle(path: String) -> String {
        return path.components(separatedBy: "/").last?.removingPercentEncoding ?? ""
    }
}
