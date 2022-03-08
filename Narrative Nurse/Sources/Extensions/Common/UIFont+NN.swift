//
//  UIFont+NN.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 18.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    enum FontType: String {
        case bold = "Bold"
        case boldOblique = "BoldOblique"
        case oblique = "Oblique"
        case regular = "Regular"
    }

    static func nn_font(type: FontType, sizeFont: CGFloat) -> UIFont {
        let nameFont = "CambayDevanagari-\(type.rawValue)"

        guard let font = UIFont(name: nameFont, size: sizeFont) else {
            assertionFailure("Font `\(nameFont)` is not found")
            return UIFont.systemFont(ofSize: sizeFont)
        }

        return font
    }

}
