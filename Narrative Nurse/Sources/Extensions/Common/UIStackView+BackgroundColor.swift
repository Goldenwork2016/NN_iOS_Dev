//
//  UIStackView+BackgroundColor.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 27.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {

    private static let backgroundViewTag = Int.random(in: 100...30000)

    open override var backgroundColor: UIColor? {
        set {
            let backgroundView: UIView

            if let view = self.viewWithTag(UIStackView.backgroundViewTag) {
                backgroundView = view
            } else {
                backgroundView = UIView()
                self.nn_addSubview(backgroundView)
            }

            self.sendSubviewToBack(backgroundView)

            backgroundView.backgroundColor = newValue
        }

        get {
            return self.viewWithTag(UIStackView.backgroundViewTag)?.backgroundColor
        }
    }

}
