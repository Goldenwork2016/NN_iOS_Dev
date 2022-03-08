//
//  NNError.swift
//  
//
//  Created by Voloshyn Slavik on 08.12.2020.
//

import Foundation

public struct NNError: Error {

    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }

}

// MARK: - LocalizedError
extension NNError: LocalizedError {

    public var errorDescription: String? {
        return self.description
    }

}
