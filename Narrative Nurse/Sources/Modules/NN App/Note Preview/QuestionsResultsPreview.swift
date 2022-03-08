//
//  QuestionsResultsPreview.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 02.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class QuestionsResultsPreview: UIView {

    private let narrativeText = UITextView()

    var onClose: VoidClosure?

    init() {
        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.isUserInteractionEnabled = true
        self.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.font = .nn_font(type: .bold, sizeFont: 40)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "Note Preview"

        let titleContainerView = UIView()
        titleContainerView.nn_addSubview(titleLabel) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30)
            ]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            titleContainerView.setBackgroundGradientColor([.nn_turquoise, .nn_lightBlue], direction: .horizontal)
        }

        self.narrativeText.textContainerInset = UIEdgeInsets(top: 31, left: 27, bottom: 31, right: 27)
        self.narrativeText.font = .nn_font(type: .regular, sizeFont: 21)
        self.narrativeText.textColor = .black
        self.narrativeText.isEditable = false
        self.narrativeText.backgroundColor = .nn_lightGray
        self.narrativeText.textAlignment = .left

        let okayButton = NNButton()
        okayButton.setTitle("Close", for: .normal)
        okayButton.backgroundColor = .white
        okayButton.addTarget(self, action: #selector(onOkayButtonClicked), for: .touchUpInside)

        let okayButtonStackView = UIStackView(arrangedSubviews: [okayButton])
        okayButtonStackView.layoutMargins = .init(top: 8, left: 30, bottom: 24, right: 30)
        okayButtonStackView.isLayoutMarginsRelativeArrangement = true
        okayButtonStackView.insetsLayoutMarginsFromSafeArea = false

        let stackView = UIStackView(arrangedSubviews: [titleContainerView, self.narrativeText, okayButtonStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.backgroundColor = .white

        self.nn_addSubview(stackView)
    }

    @objc private func onOkayButtonClicked() {
        self.onClose?()
    }

    func updateNarrative(_ narrative: String) {
        self.narrativeText.text = narrative
    }
}
