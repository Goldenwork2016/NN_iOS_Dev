//
//  TextOptionView.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 31.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class TextOptionView: OptionView {

    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    var onTap: VoidClosure?

    override var isSelected: Bool {
        didSet {
            self.titleLabel.textColor = self.isSelected ? .white : .nn_blue
        }
    }
    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    private func setupViews() {
        self.titleLabel.textColor = .nn_blue
        self.titleLabel.isUserInteractionEnabled = true

        let tapGestureRecogizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        self.titleLabel.addGestureRecognizer(tapGestureRecogizer)

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        self.nn_addSubview(self.stackView)
    }

    @objc private func tapped() {
        self.onTap?()
    }
}
