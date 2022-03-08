//
//  DraggableQuestionView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class DraggableQuestionView: UIView {

    private let expandButton = UIButton()
    private let label = UILabel()
    private let stackView = UIStackView()

    var question: Question? {
        didSet {
            self.updateViews()
        }
    }

    var offsetLevel: Int = 0 {
        didSet {
            self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: CGFloat(50 + self.offsetLevel * 20), bottom: 0, right: 0)
        }
    }

    var isExpanded: Bool = true {
        didSet {
            if self.isExpanded {
                self.expandButton.setTitle("-", for: .normal)
            } else {
                self.expandButton.setTitle("+", for: .normal)
            }
        }
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
        self.expandButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.expandButton.setTitle("+", for: .normal)
        self.expandButton.setTitleColor(.black, for: .normal)

        self.label.numberOfLines = 1

        self.stackView.addArrangedSubview(self.expandButton)
        self.stackView.addArrangedSubview(self.label)
        self.stackView.addArrangedSubview(UIView())
        self.stackView.axis = .horizontal
        self.stackView.spacing = 10
        self.stackView.isLayoutMarginsRelativeArrangement = true

        self.nn_addSubview(self.stackView)
    }

    private func updateViews() {
        self.label.text = self.question?.question

        if let question = self.question, question.children.isEmpty {
            self.expandButton.setTitle(" ", for: .normal)
        }
    }
}
