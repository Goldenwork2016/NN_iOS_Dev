//
//  NarrativeView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

final class IrregularFormView: UIView {

    private let singularLabel = UILabel()
    private let singularTextField = BuilderTextField()
    private let pluralLabel = UILabel()
    private let pluralTextField = BuilderTextField()

    var narrative: IrregularForm? {
        didSet {
            self.singularTextField.text = self.narrative?.singular
            self.pluralTextField.text = self.narrative?.plural
        }
    }

    var updatedNarrative: IrregularForm? {
        return IrregularForm(singular: self.singularTextField.text, plural: self.pluralTextField.text)
    }

    var onChanged: VoidClosure?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.singularLabel.text = "Singular: "
        self.singularLabel.textColor = .black

        self.singularTextField.placeholder = "Enter narrative here"
        self.singularTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.singularTextField.delegate = self

        self.pluralLabel.text = "Plural: "
        self.pluralLabel.textColor = .black

        self.pluralTextField.placeholder = "Enter narrative here"
        self.pluralTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.pluralTextField.delegate = self

        let singularStackView = UIStackView(arrangedSubviews: [self.singularLabel, self.singularTextField])
        singularStackView.axis = .horizontal
        singularStackView.spacing = 30

        let pluralStackView = UIStackView(arrangedSubviews: [self.pluralLabel, self.pluralTextField])
        pluralStackView.axis = .horizontal
        pluralStackView.spacing = 30

        let stackView = UIStackView(arrangedSubviews: [singularStackView, pluralStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

        self.nn_addSubview(stackView)
    }
}

extension IrregularFormView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onChanged?()
    }
}
