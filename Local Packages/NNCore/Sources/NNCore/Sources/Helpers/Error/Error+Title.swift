//
//  File.swift
//  
//
//  Created by Voloshyn Slavik on 08.12.2020.
//

import Foundation

public extension Error {

    var displayTitle: String? {
        if let nnError = self as? NNError {
            return nnError.title
        }

        return nil
    }

}
