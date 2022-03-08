//
//  UIView+RoundedCorners.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public enum ViewCornerRadius {
    case view
    case button
    case value(CGFloat)

    public var value: CGFloat {
        switch self {
        case .view:
            return 16
        case .button:
            return 4
        case .value(let v):
            return v
        }
    }
}

public extension UIView {

    func nn_roundTopCorners(radius: ViewCornerRadius) {
        self.nn_roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner],
                             radius: radius.value)
    }

    func nn_roundBottomCorners(radius: ViewCornerRadius) {
        self.nn_roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius.value)
    }

    func nn_roundAllCorners(radius: ViewCornerRadius) {
        self.nn_roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner],
                             radius: radius.value)
    }

    func nn_roundRightCorners(radius: ViewCornerRadius) {
        self.nn_roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                             radius: radius.value)
    }

    func nn_roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        self.layer.masksToBounds = true
    }
}
