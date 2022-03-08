//
//  NNRadioButton.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class NNRadioButton: UIImageView {

    var onSelected: VoidClosure?

    var isSelected: Bool = false {
        didSet {
            updateView()
        }
    }

    init() {
        super.init(frame: .zero)

        setupView()
        updateView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSwitch)))
        self.tintColor = .black
    }

    private func updateView() {
        if #available(iOS 13.0, *) {
            self.image = self.isSelected ? UIImage(systemName: "largecircle.fill.circle") : UIImage(systemName: "circle")
        }
    }

    @objc private func onSwitch() {
        self.isSelected.toggle()
        self.onSelected?()
    }

}
