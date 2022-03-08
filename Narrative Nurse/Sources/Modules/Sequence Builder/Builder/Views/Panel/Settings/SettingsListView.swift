//
//  ListKindView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsListView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let label = UILabel()
    private let multiselectionCheckmark = CheckmarkButton()
    private let multiselectionLabel = UILabel()
    var onUpdated: VoidClosure?

    var multiselection: Bool = false {
        didSet {
            self.multiselectionCheckmark.isSelected = self.multiselection
        }
    }

    var kind: Question.Kind? {
        return .list(multiselection: self.multiselection)
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
        self.label.text = nil

        self.multiselectionCheckmark.onTap = { [weak self] in
                self?.multiselectionToggled()
            }
        self.multiselectionCheckmark.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.multiselectionCheckmark.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.multiselectionLabel.text = "Multiselection"

        let multiselectionStackView = UIStackView(arrangedSubviews: [self.multiselectionCheckmark, self.multiselectionLabel])
        multiselectionStackView.axis = .horizontal
        multiselectionStackView.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [self.label, multiselectionStackView])
        stackView.axis = .vertical
        stackView.spacing = 10

        self.nn_addSubview(stackView)
    }

    private func multiselectionToggled() {
        self.multiselection.toggle()
        self.onUpdated?()
    }
}
