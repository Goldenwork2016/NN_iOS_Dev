//
//  OptionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 25.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class OptionTableViewCell: UITableViewCell {

    private let backgroundImageView = UIImageView()
    private let button = OptionButton()

    var onSelected: VoidClosure?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.nn_addSubview(self.backgroundImageView)

        self.button.backgroundColor = UIColor.clear
        self.button.titleLabel?.font = .nn_font(type: .bold, sizeFont: 21)
        self.button.setTitleColor(.nn_lightBlue, for: .normal)
        self.button.setTitleColor(.nn_orange, for: .highlighted)
        self.button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)

        self.nn_addSubview(self.button)
    }

    @objc private func buttonPressed() {
        self.onSelected?()
    }

    func setContent(title: String?, isSelected: Bool, isFirst: Bool, isLast: Bool, isNextCellSelected: Bool) {
        self.updateBackground(isSelected: isSelected, isFirst: isFirst, isLast: isLast)
        self.updateShadow(isSelected: isSelected, isNextCellSelected: isNextCellSelected)
        self.updateButton(title: title, isSelected: isSelected, isLast: isLast, isNextCellSelected: isNextCellSelected)
    }

    private func updateButton(title: String?, isSelected: Bool, isLast: Bool, isNextCellSelected: Bool) {
        if !isLast && isNextCellSelected && isSelected {
            self.button.bottomBorderColor = .white
        } else {
            self.button.bottomBorderColor = .clear
        }

        self.button.setTitle(title, for: .normal)

        if isSelected {
            self.button.setTitleColor(.nn_orange, for: .normal)
        } else {
            self.button.setTitleColor(.nn_lightBlue, for: .normal)
        }
    }

    private func updateShadow(isSelected: Bool, isNextCellSelected: Bool) {
        if isSelected && !isNextCellSelected {
            self.layer.nn_applyShadow()
        } else {
            self.layer.nn_removeShadow()
        }
    }

    private func updateBackground(isSelected: Bool, isFirst: Bool, isLast: Bool) {
        self.backgroundImageView.layer.cornerRadius = 0

        if isFirst && isSelected {
            self.backgroundImageView.nn_roundTopCorners(radius: .value(19))
        }
        if isLast && isSelected {
            self.backgroundImageView.nn_roundBottomCorners(radius: .value(19))
        }

        if isFirst && isLast && isSelected {
            self.backgroundImageView.nn_roundAllCorners(radius: .value(19))
        }

        if isSelected {
            self.backgroundImageView.backgroundColor = .white
            self.backgroundImageView.layer.borderWidth = 1
            self.backgroundImageView.layer.borderColor = UIColor.nn_midGray.cgColor
        } else {
            self.backgroundImageView.backgroundColor = .clear
            self.backgroundImageView.layer.borderWidth = 0
            self.backgroundImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }

}

final private class OptionButton: BaseButton {

    var bottomBorderColor: UIColor = .clear {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if let context = UIGraphicsGetCurrentContext() {
            let lineWidth = 1 * UIScreen.main.scale
            context.setStrokeColor(self.bottomBorderColor.cgColor)
            context.setLineWidth(lineWidth)
            context.move(to: CGPoint(x: 1, y: rect.height))
            context.addLine(to: CGPoint(x: rect.width - 1, y: rect.height))
            context.strokePath()
        }
    }

}
