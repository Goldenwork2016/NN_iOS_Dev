//
//  SettingsView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore
final class SettingsView: PanelView {

    private let outputToVariableCheckmark = CheckmarkButton()
    private let outputToVariableLabel = UILabel()
    private let ouputToVariableTextField = BuilderTextField()

    private let stackView = UIStackView()

    override var title: String {
        return "Settings"
    }

    var outputToVariable: String? {
        if self.outputToVariableCheckmark.isSelected,
           let variable = self.ouputToVariableTextField.text, !variable.isEmpty {
            return variable
        } else {
            return nil
        }
    }

    var kind: Question.Kind? {
        guard let kindSelectable = self.stackView.subviews.first(where: { ($0 as? SettingsQuestionKind) != nil }) as? SettingsQuestionKind else { return nil }

        return kindSelectable.kind
    }

    override func setupViews() {
        self.outputToVariableCheckmark.onTap = { [weak self] in
            self?.onUpdated?()
        }
        self.outputToVariableCheckmark.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.outputToVariableCheckmark.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.outputToVariableLabel.text = "Output to Variable"

        let outputToVariableStackView = UIStackView(arrangedSubviews: [self.outputToVariableCheckmark, self.outputToVariableLabel])
        outputToVariableStackView.axis = .horizontal
        outputToVariableStackView.spacing = 10

        self.ouputToVariableTextField.placeholder = "Enter variable here"
        self.ouputToVariableTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.ouputToVariableTextField.delegate = self

        self.stackView.addArrangedSubview(outputToVariableStackView)
        self.stackView.addArrangedSubview(self.ouputToVariableTextField)
        self.stackView.axis = .vertical
        self.stackView.spacing = 10
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        self.nn_addSubview(self.stackView)
    }

    override func updateViews() {
        defer {
            self.stackView.addArrangedSubview(SettingsBaseQuestionView())
        }

        self.stackView.subviews.forEach { ($0 as? SettingsBaseQuestionView)?.removeFromSuperview() }

        if let outputToVariable = self.question?.outputToVariable {
            self.outputToVariableCheckmark.isSelected = true
            self.ouputToVariableTextField.text = outputToVariable
        } else {
            self.outputToVariableCheckmark.isSelected = false
            self.ouputToVariableTextField.text = nil
        }

        let needToHideVariables: Bool
        switch self.question?.kind {
        case .reusable, .variablesToOutput:
            needToHideVariables = true
        default:
            needToHideVariables = false
        }
        self.outputToVariableLabel.isHidden = needToHideVariables
        self.outputToVariableCheckmark.isHidden = needToHideVariables
        self.ouputToVariableTextField.isHidden = needToHideVariables

        guard let question = self.question else { return }

        switch question.kind {
        case .variablesToOutput(let variables):
            let variablesView = SettingsVariablesToOutputView()
            variablesView.variables = variables
            variablesView.backgroundColor = .blue
            variablesView.sequnce = self.sequence
            variablesView.onUpdated = self.onUpdated
            self.stackView.addArrangedSubview(variablesView)
        case .image(let filename, let multiselection):
            let imageSelectorView = SettingsImageSelectorView()
            imageSelectorView.filename = filename
            imageSelectorView.multiselection = multiselection
            imageSelectorView.onUpdated = self.onUpdated
            imageSelectorView.onPresentPicker = { filenames, completion in
                NNDropDown.show(anchor: imageSelectorView, items: filenames) { (_, value) in
                    completion(value)
                }
            }
            self.stackView.addArrangedSubview(imageSelectorView)
        case .reusable(let filename):
            let reusableSelectorView = SettingsReusableSelectorView()
            reusableSelectorView.filename = filename
            reusableSelectorView.onPresentFileSelector = self.onPresentFileSelector
            reusableSelectorView.onUpdated = self.onUpdated
            self.stackView.addArrangedSubview(reusableSelectorView)
        case .size:
            let kindView = SettingsSizeView()
            kindView.title = nil
            self.stackView.addArrangedSubview(kindView)
        case .dateTime(let formatter):
            let kindView = SettingsDateTimeView()
            kindView.formatter = formatter
            kindView.onUpdated = self.onUpdated
            self.stackView.addArrangedSubview(kindView)
        case .list(let multiselection):
            let listView = SettingsListView()
            listView.multiselection = multiselection
            listView.onUpdated = self.onUpdated
            self.stackView.addArrangedSubview(listView)
        case .grouped(let linkingVerb, let order):
            let kindView = SettingsGroupQuestionView()
            kindView.linkingVerb = linkingVerb
            kindView.order = order
            kindView.onUpdate = self.onUpdated
            self.stackView.addArrangedSubview(kindView)
        }
    }
}

extension SettingsView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onUpdated?()
    }
}
