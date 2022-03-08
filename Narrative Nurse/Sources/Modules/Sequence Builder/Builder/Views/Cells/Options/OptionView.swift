//
//  OptionView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 31.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

class OptionView: UIView {

    var isSelected: Bool = false {
        didSet {
            self.backgroundColor = self.isSelected ? .systemBlue : .clear
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
