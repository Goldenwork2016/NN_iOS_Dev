//
//  NSObject+ClassName.swift
//
//  Created by Voloshyn Slavik
//

import Foundation

public extension NSObject {
    @objc class var classFullName: String {
        return String(reflecting: self)
    }

    @objc class var className: String {
        return String(describing: self)
    }

    @objc var classFullName: String {
        return type(of: self).classFullName
    }

    @objc var className: String {
        return type(of: self).className
    }
}
