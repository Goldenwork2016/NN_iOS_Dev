//
//  ListOptionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AnswerListOptionTableViewCell: UITableViewCell, AnswerOptionCell {

    private let titleTextField = BuilderTextField()
    private let narrativeTextField = BuilderTextField()
    private let noneCheckmard = CheckmarkButton()
    private let noneLabel = UILabel()

    private var isNone: Bool = false {
        didSet {
            self.noneCheckmard.isSelected = self.isNone
        }
    }

    private var option: Option?
    var editedOption: Option? {
        guard let option = self.option else { return nil }
        if self.isNone {
            return Option(kind: .none(title: self.titleTextField.text ?? option.kind.title ?? ""), narrative: self.narrativeTextField.text ?? option.narrative, id: option.id)
        } else {
            return Option(kind: .text(title: self.titleTextField.text ?? option.kind.title ?? ""), narrative: self.narrativeTextField.text ?? option.narrative, id: option.id)
        }
    }
    var onEdit: VoidClosure?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    func setOption(_ option: Option) {
        self.option = option
        self.updateViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.titleTextField.placeholder = "Title"
        self.titleTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.titleTextField.addTarget(self, action: #selector(self.onTextFieldUpdated), for: .editingChanged)

        self.narrativeTextField.placeholder = "Narrative"
        self.narrativeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.narrativeTextField.addTarget(self, action: #selector(self.onTextFieldUpdated), for: .editingChanged)

        self.noneCheckmard.onTap = { [weak self] in
            self?.noneToggled()
        }
        self.noneCheckmard.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.noneCheckmard.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.noneLabel.text = "None"

        let noneStackView = UIStackView(arrangedSubviews: [self.noneCheckmard, self.noneLabel])
        noneStackView.axis = .horizontal
        noneStackView.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [self.titleTextField, self.narrativeTextField, noneStackView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        self.contentView.nn_addSubview(stackView)
    }

    private func updateViews() {
        guard let option = self.option else { return }

        self.titleTextField.text = option.kind.title
        self.narrativeTextField.text = option.narrative
        self.isNone = option.kind.isNone
    }

    private func noneToggled() {
        self.isNone.toggle()
        self.onEdit?()
    }

    @objc private func onTextFieldUpdated() {
        self.onEdit?()
    }
}
