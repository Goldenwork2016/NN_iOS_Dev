//
//  QuestionKind.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

extension Question {

    public enum Kind: Codable, Equatable {

        enum QuestionType: String {
            case list
            case image
            case dateTime
            case size
            case reusable
            case grouped
            case variablesToOutput
        }

        enum Keys: String, CodingKey {
            case imagePath
            case multiselection
            case type
            case filename
            case variablesToOutput
            case format
            case linkingVerb
            case outputOrder
        }

        public var isVariables: Bool {
            switch self {
            case .variablesToOutput:
                return true
            default:
                return false
            }
        }

        public var isMultiselection: Bool {
            switch self {
            case .list(let multiselection):
                return multiselection
            case .image(_, let multiselection):
                return multiselection
            default:
                return false
            }
        }

        public var title: String {
            switch self {
            case .dateTime:
                return "Date/Time"
            case .size:
                return "Size"
            case .grouped:
                return "Grouped"
            case .variablesToOutput:
                return "Variables to output"
            case .reusable:
                return "Reusable"
            case .list:
                return "List"
            case .image:
                return "Image"
            }
        }

        case dateTime(formatter: NNDateFormatter)
        case size
        case grouped(linkingVerb: IrregularForm, order: QroupQuestionOrder)
        case variablesToOutput(variables: [String])
        case reusable(filename: String)
        case list(multiselection: Bool)
        case image(imagePath: String, multiselection: Bool)

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            let typeString = try container.decode(String.self, forKey: .type)

            guard let type = QuestionType(rawValue: typeString) else {
                assertionFailure("Parsing error: Unsupported question type")
                self = .list(multiselection: false)
                return
            }

            if type == .list, let multiselection = try? container.decode(Bool.self, forKey: .multiselection) {
                self = .list(multiselection: multiselection)
            } else if type == .image, let imagePath = try? container.decode(String.self, forKey: .imagePath),
                      let multiselection = try? container.decode(Bool.self, forKey: .multiselection) {
                self = .image(imagePath: imagePath, multiselection: multiselection)
            } else if type == .dateTime, let format = try? container.decode(String.self, forKey: .format) {
                let dateFormatter = NNDateFormatter(format: format)
                self = .dateTime(formatter: dateFormatter)
            } else if type == .size {
                self = .size
            } else if type == .grouped,
                      let linkingVerb = try? container.decode(IrregularForm.self, forKey: .linkingVerb),
                      let order = try? container.decode(QroupQuestionOrder.self, forKey: .outputOrder) {
                self = .grouped(linkingVerb: linkingVerb, order: order)
            } else if type == .variablesToOutput, let variablesToOutput = try? container.decode([String].self, forKey: .variablesToOutput) {
                self = .variablesToOutput(variables: variablesToOutput)
            } else if type == .reusable, let filename = try? container.decode(String.self, forKey: .filename) {
                self = .reusable(filename: filename)
            } else {
                self = .list(multiselection: false)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)

            switch self {
            case .size:
                try container.encode(QuestionType.size.rawValue, forKey: .type)
            case .grouped(let linkingVerb, let order):
                try container.encode(QuestionType.grouped.rawValue, forKey: .type)
                try container.encode(linkingVerb, forKey: .linkingVerb)
                try container.encode(order, forKey: .outputOrder)
            case .variablesToOutput(let variablesToOutput):
                try container.encode(QuestionType.variablesToOutput.rawValue, forKey: .type)
                try container.encode(variablesToOutput, forKey: .variablesToOutput)
            case .reusable(let filename):
                try container.encode(QuestionType.reusable.rawValue, forKey: .type)
                try container.encode(filename, forKey: .filename)
            case .dateTime(let formatter):
                try container.encode(QuestionType.dateTime.rawValue, forKey: .type)
                try container.encode(formatter.format, forKey: .format)
            case .image(let imagePath, let multiselection):
                try container.encode(QuestionType.image.rawValue, forKey: .type)
                try container.encode(imagePath, forKey: .imagePath)
                try container.encode(multiselection, forKey: .multiselection)
            case .list(let multiselection):
                try container.encode(QuestionType.list.rawValue, forKey: .type)
                try container.encode(multiselection, forKey: .multiselection)
            }
        }
    }

}
