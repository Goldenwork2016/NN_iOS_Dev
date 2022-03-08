//
//  NNSelectableButton.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 08.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class NNSelectableButton: UIView {

    private let backgroundView = UIView()
    let button = UIButton()

    var isSelected: Bool {
        set {
            self.button.isSelected = newValue
            updateState()
        }
        get {
            return self.button.isSelected
        }
    }

    var title: String? {
        set {
            self.button.setTitle(newValue, for: .normal)
        }
        get {
            return self.button.title(for: .normal)
        }
    }

    override var tag: Int {
        set {
            button.tag = newValue
        }
        get {
            return button.tag
        }
    }

    init() {
        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.clipsToBounds = false

        self.backgroundView.backgroundColor = .white
        self.backgroundView.layer.borderWidth = 1.0
        self.backgroundView.layer.borderColor = UIColor.nn_midGray.cgColor
        self.backgroundView.nn_roundAllCorners(radius: .value(16))
        self.nn_addSubview(self.backgroundView)

        self.button.titleLabel?.font = .nn_font(type: .bold, sizeFont: 30)
        self.button.setTitleColor(.nn_lightBlue, for: .normal)
        self.button.setTitleColor(.nn_orange, for: .selected)
        self.button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        self.nn_addSubview(self.button)

        updateState()
    }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        self.button.addTarget(target, action: action, for: controlEvents)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateState()
    }

    private func updateState() {
        if self.isSelected {
            self.backgroundView.isHidden = false
            self.layer.nn_applyShadow()
        } else {
            self.backgroundView.isHidden = true
            self.layer.nn_removeShadow()
        }
    }
}
