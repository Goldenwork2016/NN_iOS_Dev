//
//  NNDropDown.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 29.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import DropDown

final class NNDropDown {

    private init() {}

    static func show(anchor: AnchorView, items: [String], offset: Offset? = nil, width: CGFloat? = nil, closure: SelectionClosure?) {
        let dropDown = DropDown()
        dropDown.anchorView = anchor
        dropDown.dataSource = items
        dropDown.selectionAction = closure
        dropDown.backgroundColor = .nn_lightGray
        dropDown.cornerRadius =  19
        dropDown.direction = .any
        dropDown.width = width

        switch offset {
        case .top(let value):
            dropDown.topOffset = CGPoint(x: 0, y: value)
        case .bottom(let value):
            dropDown.bottomOffset = CGPoint(x: 0, y: value)
        default:
            break
        }

        dropDown.textFont = .nn_font(type: .bold, sizeFont: 21)
        dropDown.textColor = .nn_lightBlue
        dropDown.show()
    }

    enum Offset {
        case top(value: CGFloat)
        case bottom(value: CGFloat)
    }
}
