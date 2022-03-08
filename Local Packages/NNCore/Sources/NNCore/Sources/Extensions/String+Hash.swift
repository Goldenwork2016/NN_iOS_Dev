//
//  File.swift
//  
//
//  Created by Voloshyn Slavik on 15.12.2020.
//

import Foundation

public extension String {

    var uniqueHash: UInt64 {
        var result = UInt64(5381)
         let buf = [UInt8](self.utf8)
         for b in buf {
             result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
         }
         return result
    }

}
