//
//  SequencesProvider.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 27.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

final public class SequencesProvider {

    public init() {
    }

    public func getSequence(for item: Facility, job: JobTitle) -> QuestionsSequence {
        let file: File = .sequence(job, item)
        if let path = Bundle.main.path(forResource: file.path, ofType: file.type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let questionsSequence = try JSONDecoder().decode(QuestionsSequence.self, from: data)

                return questionsSequence
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return QuestionsSequence.empty
    }

    public func loadQuestion(with filename: Identifier, from source: SequenceSource) -> Question? {
        switch source {
        case .project:
            let file = File.question(filename)
            if let path = Bundle.main.path(forResource: file.path, ofType: file.type) {
                return loadObject(by: URL(fileURLWithPath: path))
            }
        case .local:
            let fileManager = FileManager.default
            if let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                let fileURL = documentDirectory.appendingPathComponent(filename).appendingPathExtension("json")
                return loadObject(by: fileURL)
            }
        }

        return nil
    }

    public func loadObject<Object: Codable>(by url: URL) -> Object? {
        do {
            let data = try Data(contentsOf: url)
            let questionsSequence = try JSONDecoder().decode(Object.self, from: data)
            return questionsSequence
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    @discardableResult
    public func saveObject<Object: Encodable>(object: Object, with filename: String, fileType: SequenceFileType) -> URL? {
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent(filename).appendingPathExtension("json")
            saveObject(object: object, by: fileURL, fileType: fileType)
            return fileURL
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    public func saveObject<Object: Encodable>(object: Object, by url: URL, fileType: SequenceFileType) {
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: url)
            var url = url
            url.sequenceFileType = fileType
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
