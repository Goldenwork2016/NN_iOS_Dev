//
//  TextFieldOptionView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 04.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class TextFieldOptionView: OptionView {

    private let titleLabel = UILabel()
    private let valueTextField = UITextField()
    private let stackView = UIStackView()

    var onChanged: OptionalStringClosure?
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
    var value: String? {
        didSet {
            self.valueTextField.text = value
        }
    }

    private var isKeyboardVisible = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
        self.subscribeForKeyboardNotifications()
    }

    private func setupViews() {
        self.titleLabel.textColor = .nn_blue
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClearSelection)))

        self.stackView.addArrangedSubview(self.titleLabel)

        self.valueTextField.keyboardType = .numberPad
        self.valueTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.valueTextField.borderStyle = .roundedRect
        self.valueTextField.delegate = self
        self.stackView.addArrangedSubview(self.valueTextField)

        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.stackView.spacing = 10

        self.nn_addSubview(self.stackView)
    }

    private func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func didShow() {
        self.isKeyboardVisible = true
    }

    @objc private func didHide() {
        self.isKeyboardVisible = false
    }

    @objc private func onClearSelection() {
        if self.isKeyboardVisible {
            UIApplication.topViewController()?.view.endEditing(true)
        } else {
            self.onTap?()
        }
    }
}

extension TextFieldOptionView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Workaround for jumpung text after loosing a focus
        textField.setNeedsLayout()
        textField.layoutIfNeeded()

        self.onChanged?(self.valueTextField.text)
    }

}
