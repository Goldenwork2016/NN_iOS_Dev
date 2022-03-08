//
//  GlobalSettingItemCell.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 26.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class EditGlobalSettingItemCell: UITableViewCell {

    private let keyTextField = BuilderTextField()
    private let valueTextField = BuilderTextField()

    var onEdit: ((String, String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.keyTextField.addTarget(self, action: #selector(self.onFieldEdited), for: .editingChanged)
        self.valueTextField.addTarget(self, action: #selector(self.onFieldEdited), for: .editingChanged)

        let stackView = UIStackView(arrangedSubviews: [self.keyTextField, self.valueTextField])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 3, left: 20, bottom: 3, right: 20)

        self.contentView.nn_addSubview(stackView, layoutConstraints: UIView.nn_constraintsCoverFull)
    }

    @objc private func onFieldEdited() {
        self.onEdit?(self.keyTextField.text ?? "", self.valueTextField.text ?? "")
    }

    func update(with key: String, and value: String) {
        self.keyTextField.text = key
        self.valueTextField.text = value
    }
}
