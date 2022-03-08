//
//  NarrativeView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class IrregularFormView: UIView {

    private let titleLabel = UILabel()
    private let singularTextField = BuilderTextField()
    private let pluralTextField = BuilderTextField()

    var title: String {
        set {
            self.titleLabel.text = newValue
        }
        get {
            self.titleLabel.text ?? ""
        }
    }

    var updatedNarrative: IrregularForm? {
        return IrregularForm(singular: self.singularTextField.text, plural: self.pluralTextField.text)
    }

    var onChanged: VoidClosure?

    func setIrregularForm(_ irregularForm: IrregularForm) {
        self.singularTextField.text = irregularForm.singular
        self.pluralTextField.text = irregularForm.plural
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.titleLabel.textColor = .black

        self.singularTextField.placeholder = "Singular"
        self.singularTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.singularTextField.delegate = self

        self.pluralTextField.placeholder = "Plural"
        self.pluralTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.pluralTextField.delegate = self

        let singularStackView = UIStackView(arrangedSubviews: [self.singularTextField])
        singularStackView.axis = .horizontal
        singularStackView.spacing = 10
        singularStackView.distribution = .fill

        let pluralStackView = UIStackView(arrangedSubviews: [self.pluralTextField])
        pluralStackView.axis = .horizontal
        pluralStackView.spacing = 10
        pluralStackView.distribution = .fill

        let stackView = UIStackView(arrangedSubviews: [titleLabel, singularStackView, pluralStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        self.nn_addSubview(stackView)
    }
}

extension IrregularFormView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onChanged?()
    }
}
