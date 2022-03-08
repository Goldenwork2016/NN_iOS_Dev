//
//  Option+Kind.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

extension Option {

    public enum Kind: Hashable {
        public static func == (lhs: Option.Kind, rhs: Option.Kind) -> Bool {
            return lhs.title == rhs.title
        }

        case text(title: String)
        case repetitive(id: Identifier, title: String)
        case polygon(polygon: [Double], title: String)
        case size(title: String, unit: String)
        case none(title: String)
        case grouped(title: String, beforeGroup: IrregularForm, afterGroup: IrregularForm, children: [Option], options: [Option])
        case groupedOverride(title: String, children: [Option])

        public var title: String? {
            if case Kind.text(let title) = self {
                return title
            } else if case Kind.repetitive(_, let title) = self {
                return title
            } else if case Kind.size(let title, _) = self {
                return title
            } else if case Kind.none(let title) = self {
                return title
            } else if case Kind.grouped(let title, _, _, _, _) = self {
                return title
            } else if case Kind.groupedOverride(let title, _) = self {
                return title
            } else if case Kind.polygon(_, let title) = self {
                return title
            } else {
                return nil
            }
        }

        public var unit: String? {
            switch self {
            case .size(_, let unit):
                return unit
            default:
                return nil
            }
        }

        public var isNone: Bool {
            switch self {
            case .none:
                return true
            default:
                return false
            }
        }

        public var isParent: Bool {
            switch self {
            case .groupedOverride:
                return true
            default:
                return false
            }
        }

        public var children: [Option] {
            switch self {
            case .grouped(_, _, _, let children, _):
                return children
            case .groupedOverride(_, let children):
                return children
            default:
                return []
            }
        }

        public var options: [Option] {
            switch self {
            case .grouped(_, _, _, _, let options):
                return options
            default:
                return []
            }
        }
    }

}
