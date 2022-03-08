//
//  SelectorOptionView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 04.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SelectorOptionView: OptionView {
    
    private let titleLabel = UILabel()
    private let valueTextField = UITextField()
    private let stackView = UIStackView()
    
    var onChanged: OptionalStringClosure?
    
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
    var items: [String] = []
    var selectedValue: String? {
        didSet {
            self.valueTextField.text = self.selectedValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    private func setupViews() {

        self.titleLabel.textColor = .nn_blue
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClearSelection)))
        self.stackView.addArrangedSubview(self.titleLabel)
        
        self.valueTextField.keyboardType = .decimalPad
        self.valueTextField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.valueTextField.borderStyle = .roundedRect
        self.valueTextField.delegate = self

        self.stackView.addArrangedSubview(self.valueTextField)
        
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.stackView.spacing = 10
        
        self.nn_addSubview(self.stackView)
    }
    
    @objc private func onClearSelection() {
        self.selectedValue = nil
        self.onChanged?(self.selectedValue)
    }
}

extension SelectorOptionView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NNDropDown.show(anchor: textField, items: self.items) { [weak self] (_, value) in
            self?.selectedValue = value
            self?.onChanged?(value)
        }
        return false
    }
}
