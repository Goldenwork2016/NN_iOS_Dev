//
//  NNButton.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 25.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class NNButton: UIButton {

    let fixedHeight: Bool

    override init(frame: CGRect) {
        self.fixedHeight = true

        super.init(frame: frame)

        self.setupViews()
    }

    init(frame: CGRect, fixedHeight: Bool) {
        self.fixedHeight = fixedHeight

        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let selectedColor = UIColor(red: 129.0/255.0, green: 74.0/255.0, blue: 37.0/255.0, alpha: 1.0)

        self.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)
        self.setTitleColor(.nn_orange, for: .normal)
        self.setTitleColor(selectedColor, for: .focused)
        self.setTitleColor(selectedColor, for: .highlighted)
        self.setTitleColor(selectedColor, for: .selected)

    }
}
