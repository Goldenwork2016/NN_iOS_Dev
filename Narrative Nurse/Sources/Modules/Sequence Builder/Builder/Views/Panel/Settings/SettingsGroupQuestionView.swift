//
//  GroupQuestionKindView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class SettingsGroupQuestionView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let linkingVerbView = IrregularFormView()
    private var orderRadioButons: [NNRadioButton] = []

    var onUpdate: VoidClosure?

    var linkingVerb: IrregularForm {
        set {
            self.linkingVerbView.setIrregularForm(newValue)
        }
        get {
            self.linkingVerbView.updatedNarrative ?? IrregularForm(singular: nil, plural: nil)
        }
    }

    var order: QroupQuestionOrder = .questionAnswer {
        didSet {
            updateOrderRadioButons()
        }
    }

    var kind: Question.Kind? {
        return .grouped(linkingVerb: self.linkingVerb, order: self.order)
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
        var views: [UIView] = []
        views.append(UIView())

        let orderLabel = UILabel()
        orderLabel.text = "Question and answer position in narrative output"
        orderLabel.textColor = .black
        orderLabel.numberOfLines = 0
        views.append(orderLabel)

        for i in QroupQuestionOrder.allCases.indices {
            let order = QroupQuestionOrder.allCases[i]
            let radioButton = NNRadioButton()
            radioButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            radioButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            radioButton.onSelected = { [weak self] in
                self?.order = order
                self?.onUpdate?()
            }

            let titleLabel = UILabel()
            titleLabel.text = order.title
            titleLabel.textColor = .black

            let radioButtonStackView = UIStackView(arrangedSubviews: [radioButton, titleLabel])
            radioButtonStackView.axis = .horizontal
            radioButtonStackView.spacing = 10

            views.append(radioButtonStackView)
            self.orderRadioButons.append(radioButton)
        }

        views.append(UIView())

        self.linkingVerbView.title = "Define linking verbs"
        self.linkingVerbView.onChanged = { [weak self] in
            self?.onUpdate?()
        }
        views.append(self.linkingVerbView)

        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 10

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

    private func updateOrderRadioButons() {
        self.orderRadioButons.forEach { $0.isSelected = false }
        if let index = QroupQuestionOrder.allCases.firstIndex(where: { $0 == self.order }),
           let radioButton = self.orderRadioButons[safe: index] {
            radioButton.isSelected = true
        }
    }

}
