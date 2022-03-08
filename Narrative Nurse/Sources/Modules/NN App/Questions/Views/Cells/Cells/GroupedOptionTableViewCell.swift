//
//  GroupedOptionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 15.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class GroupedOptionTableViewCell: UITableViewCell {

    private let backgroundImageView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    let containerView = UIView()

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

        self.containerView.nn_addSubview(self.backgroundImageView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 1)
            ]
        }

        self.titleLabel.font = .nn_font(type: .bold, sizeFont: 21)
        self.titleLabel.textAlignment = .center

        self.valueLabel.font = .nn_font(type: .bold, sizeFont: 21)
        self.valueLabel.textAlignment = .center
        self.valueLabel.textColor = .nn_orange

        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        self.containerView.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ]
        }

        self.contentView.nn_addSubview(self.containerView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ]
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onSelectClicked))
        self.containerView.addGestureRecognizer(tapGesture)
    }

    @objc private func onSelectClicked() {
        self.onSelected?()
    }

    func setContent(title: String?, selectedValue: String?, isLast: Bool, isNextCellSelected: Bool) {
        let isSelected = selectedValue != nil

        self.updateBackground(isSelected: isSelected, isLast: isLast)
        self.updateShadow(isSelected: isSelected, isNextCellSelected: isNextCellSelected)
        self.updateLabels(title: title, selectedValue: selectedValue, isSelected: isSelected)
    }

    private func updateLabels(title: String?, selectedValue: String?, isSelected: Bool) {
        self.titleLabel.textColor = isSelected ? .nn_orange : .nn_lightBlue
        self.titleLabel.text = title
        self.valueLabel.isHidden = !isSelected
        self.valueLabel.text = selectedValue
    }

    private func updateShadow(isSelected: Bool, isNextCellSelected: Bool) {
        if isSelected && !isNextCellSelected {
            self.containerView.layer.nn_applyShadow()
        } else {
            self.containerView.layer.nn_removeShadow()
        }
    }

    private func updateBackground(isSelected: Bool, isLast: Bool) {

        if isLast && isSelected {
            self.backgroundImageView.nn_roundBottomCorners(radius: .value(19))
        } else {
            self.backgroundImageView.nn_roundAllCorners(radius: .value(0))
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
