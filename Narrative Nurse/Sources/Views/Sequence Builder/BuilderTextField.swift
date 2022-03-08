//
//  TextFieldWithPadding.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class BuilderTextField: UITextField {

    private let padding: UIEdgeInsets

    private var leadingHintLabelConstraint = NSLayoutConstraint()
    private var topHintLabelConstraint = NSLayoutConstraint()

    private lazy var  hintLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = self.font
        label.textColor = .white
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.65)

        UIApplication.topViewController()?.view?.nn_addSubview(label, layoutConstraints: { (view, container) -> [NSLayoutConstraint] in
            self.leadingHintLabelConstraint = view.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            self.topHintLabelConstraint = view.topAnchor.constraint(equalTo: container.topAnchor)

            return [
                self.leadingHintLabelConstraint,
                self.topHintLabelConstraint,
                view.widthAnchor.constraint(equalToConstant: self.frame.width),
                view.heightAnchor.constraint(greaterThanOrEqualToConstant: self.frame.height)
            ]
        })

        return label
    }()

    init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)) {
        self.padding = padding

        super.init(frame: .zero)

        self.autocorrectionType = .no

        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 10

        self.setupNotifications()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
}

// MARK: - Setup notifications
extension BuilderTextField {

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onActivated(notification:)), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDeactivated(notification:)), name: UITextField.textDidEndEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChanged(notification:)), name: UITextField.textDidChangeNotification, object: self)
    }

    @objc private func onActivated(notification: Notification) {
        // Workaround for jumpung text after loosing a focus
        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.hintLabel.text = self.text

        let yOffset = self.frame.height + 10
        let frame = self.frame.offsetBy(dx: 0, dy: yOffset)
        let newFrame = self.hintLabel.superview?.convert(frame, from: self.superview) ?? self.frame
        self.leadingHintLabelConstraint.constant = newFrame.minX
        self.topHintLabelConstraint.constant = newFrame.minY

        UIView.setAnimationsEnabled(false)
        self.hintLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.setAnimationsEnabled(true)
        }
    }

    @objc private func onDeactivated(notification: Notification) {
        self.hintLabel.isHidden = true

        // Workaround for jumpung text after loosing a focus
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc private func onChanged(notification: Notification) {
        self.hintLabel.text = self.text
    }
}
