//
//  CheckmarkButton.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class CheckmarkButton: UIView {

    private let checkmarkImageView = UIImageView()

    var isSelected: Bool = false {
        didSet {
            self.checkmarkImageView.isHidden = !self.isSelected
        }
    }

    var onTap: VoidClosure?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = .white

        self.checkmarkImageView.isHidden = true
        if #available(iOS 13.0, *) {
            self.checkmarkImageView.image = UIImage(systemName: "checkmark")
        }
        self.checkmarkImageView.tintColor = .black
        self.checkmarkImageView.isUserInteractionEnabled = true

        self.nn_addSubview(self.checkmarkImageView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 1),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 1),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -1),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1)
            ]
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func didTap() {
        self.isSelected.toggle()

        self.onTap?()
    }
}
