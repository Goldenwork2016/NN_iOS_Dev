//
//  AppendView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AppendView: PanelView {

    override var title: String {
        return "Append"
    }

    private let narrativeBeforeLabel = UILabel()
    private let narrativeBefore = IrregularFormView()
    private let narrativeAfterLabel = UILabel()
    private let narrativeAfter = IrregularFormView()
    private let narrativeAfterChildrenLabel = UILabel()
    private let narrativeAfterChildren = BuilderTextField()

    var narrative: Narrative? {
        return Narrative(before: self.narrativeBefore.updatedNarrative, after: self.narrativeAfter.updatedNarrative, afterChildren: self.narrativeAfterChildren.text)
    }

    override func setupViews() {
        self.narrativeBefore.title = "Narrative Before:"

        self.narrativeBefore.onChanged = { [weak self] in
           self?.onUpdated?()
        }

        self.narrativeAfter.title = "Narrative After:"

        self.narrativeAfter.onChanged = { [weak self] in
            self?.onUpdated?()
        }

        self.narrativeAfterChildrenLabel.text = "After Children:"
        self.narrativeAfterChildrenLabel.textColor = .black

        self.narrativeAfterChildren.placeholder = "Enter narrative here"
        self.narrativeAfterChildren.delegate = self
        self.narrativeAfterChildren.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stackView = UIStackView(arrangedSubviews: [self.narrativeBeforeLabel, self.narrativeBefore, self.narrativeAfterLabel, self.narrativeAfter, self.narrativeAfterChildrenLabel, self.narrativeAfterChildren, UIView()])
        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        let scrollView = UIScrollView()
        scrollView.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
        }

        self.nn_addSubview(scrollView)
    }

    override func updateViews() {
        self.narrativeBefore.setIrregularForm(self.question?.narrative?.before ?? .init(singular: nil, plural: nil))
        self.narrativeAfter.setIrregularForm(self.question?.narrative?.after ?? .init(singular: nil, plural: nil))
        self.narrativeAfterChildren.text = self.question?.narrative?.afterChildren
    }
}

extension AppendView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onUpdated?()
    }
}
