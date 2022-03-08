//
//  SizeOptionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AnswerSizeOptionTableViewCell: UITableViewCell, AnswerOptionCell {

    private let titleTextField = BuilderTextField()
    private let unitTextField = BuilderTextField()
    private let narrativeTextField = BuilderTextField()

    private var option: Option?
    var editedOption: Option? {
        guard let option = self.option else { return nil }
        return Option(kind: .size(title: self.titleTextField.text ?? "", unit: self.unitTextField.text ?? ""), narrative: self.narrativeTextField.text ?? option.narrative, id: option.id)
    }

    var onEdit: VoidClosure?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOption(_ option: Option) {
        self.option = option
        self.updateViews()
    }

    private func setupViews() {
        self.titleTextField.placeholder = "Title"
        self.titleTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)
        self.titleTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.unitTextField.placeholder = "Unit"
        self.unitTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)
        self.unitTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.narrativeTextField.placeholder = "Separator"
        self.narrativeTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)
        self.narrativeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stackView = UIStackView(arrangedSubviews: [self.titleTextField, self.unitTextField, self.narrativeTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        self.contentView.nn_addSubview(stackView)
    }

    private func updateViews() {
        guard let option = self.option, case Option.Kind.size(let title, let unit) = option.kind else { return }

        self.titleTextField.text = title
        self.unitTextField.text = unit
        self.narrativeTextField.text = option.narrative
    }

    @objc private func onTextEdited() {
        self.onEdit?()
    }
}
