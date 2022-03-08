//
//  UIView+GradientColor.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 20.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIView {

    enum GradientColorDirection {
        case vertical
        case horizontal
    }

    func setBackgroundGradientColor(_ colors: [UIColor], opacity: Float = 1, direction: GradientColorDirection = .vertical) {
        setBackgroundGradientColor(colors, opacity: opacity, direction: direction, bounds: self.bounds)
    }

    func setBackgroundGradientColor(_ colors: [UIColor], opacity: Float = 1, direction: GradientColorDirection = .vertical, bounds: CGRect) {
        self.layer.sublayers?
            .compactMap { $0 as? GradientColorLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradientLayer = GradientColorLayer()
        gradientLayer.opacity = opacity
        gradientLayer.colors = colors.map { $0.cgColor }

        if case .horizontal = direction {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        }

        gradientLayer.bounds = bounds
        gradientLayer.anchorPoint = CGPoint.zero
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

}

private class GradientColorLayer: CAGradientLayer { }
