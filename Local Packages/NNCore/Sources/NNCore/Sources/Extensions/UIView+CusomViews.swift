//
//  UIView+CusomViews.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 25.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIView {

    static func roundedViewWithShadow(view: UIView, cornerRadius: CGFloat) -> UIView {
        let roundedView = UIView.viewWithRoundedCorners(value: cornerRadius)
        roundedView.nn_addSubview(view)
        let shadowView = UIView.viewWithShadow()
        shadowView.nn_addSubview(roundedView)

        return shadowView
    }

    static func viewWithShadow() -> UIView {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 5)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 5
        shadowView.layer.masksToBounds = false

        return shadowView
    }

    static func viewWithRoundedCorners(value: CGFloat) -> UIView {
        let roundedView = UIView()
        roundedView.layer.cornerRadius = value
        roundedView.clipsToBounds = true

        return roundedView
    }
}
