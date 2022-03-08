//
//  File.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 20.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {

    func nn_applyShadow(
        color: UIColor = UIColor.black.withAlphaComponent(0.4),
        alpha: Float = 1.0,
        x: CGFloat = 0,
        y: CGFloat = 15,
        blur: CGFloat = 10,
        spread: CGFloat = -15) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = alpha
        self.shadowOffset = CGSize(width: x, height: y)
        self.shadowRadius = blur / 2.0
        if spread == 0 {
            self.shadowPath = nil
        } else {
            let dx = -spread
            let rect = self.bounds.insetBy(dx: dx, dy: dx)
            self.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func nn_removeShadow() {
        self.shadowColor = nil
        self.shadowOpacity = 0
        self.shadowOffset = .zero
        self.shadowRadius = 0
        self.shadowPath = nil
    }

}
