//
//  UIBezierPath+CGPoints.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 10.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIBezierPath {
    static func makePath(for points: [CGPoint]) -> UIBezierPath? {
        guard let startPoint = points.first else { return nil }

        let path = UIBezierPath()
        path.move(to: startPoint)

        for index in 1...points.count - 1 {
            path.addLine(to: points[index])
        }

        path.close()

        return path
    }
}
