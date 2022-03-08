//
//  QuestionsBaseCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

class QuestionsBaseCell: UICollectionViewCell {

    private let questionLabel = UILabel()

    let cardView = UIView()

    var onOptions: OptionsClosure?

    var onReadyToGoNext: BoolClosure?
    var onNext: VoidClosure?

    var question: Question?

    private var openQuestionDate = Date()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getSelectedOptions() -> [Option] {
        fatalError("Should be overriden")
    }

    func setupViews() {
        let questionLabelContainerView = UIView()
        questionLabelContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 71).isActive = true

        self.questionLabel.font = .nn_font(type: .boldOblique, sizeFont: 30)
        self.questionLabel.textColor = .white
        self.questionLabel.numberOfLines = 0
        self.questionLabel.textAlignment = .center

        questionLabelContainerView.nn_addSubview(self.questionLabel) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
            ]
        }

        let stackView = UIStackView(arrangedSubviews: [questionLabelContainerView.nn_wrappedWithGradientView(), self.cardView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0

        self.contentView.nn_addSubview(stackView)
    }

    func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        self.question = question

        self.questionLabel.text = question.question

        self.openQuestionDate = Date()
    }

    func logTimeSpentForQuestion() {
        let interval = Date().timeIntervalSince(self.openQuestionDate)

        Analytics.shared.logEvent(Event.sequenceAnsweredQuestion(duration: interval))
    }
}
