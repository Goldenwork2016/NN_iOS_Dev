//
//  SelectAnswerCell.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SelectAnswerCell: UITableViewCell {

    private let scrollView = UIScrollView()
    private let expandButton = UIButton()
    private let label = UILabel()
    private let stackView = UIStackView()
    private let optionsStackView = UIStackView()
    private let checkmark = CheckmarkButton()

    var question: Question? {
        didSet {
            self.updateViews()
        }
    }

    var offsetLevel: Int {
        set {
            self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: CGFloat(30 + newValue * 20), bottom: 0, right: 0)
        }
        get {
            return Int((self.stackView.layoutMargins.left - 30) / 20)
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

    var isCheckMarkHidden: Bool {
        set {
            self.checkmark.isHidden = newValue
        }
        get {
            self.checkmark.isHidden
        }
    }
    var isQuestionSelected: Bool {
        set {
            self.checkmark.isSelected = newValue
        }
        get {
            self.checkmark.isSelected
        }
    }
    private var options: [Option] {
        return self.question?.options ?? []
    }

    var onExpand: VoidClosure?
    var onSelectOption: ((Option) -> Void)?
    var onSelectQuestion: VoidClosure? {
        set {
            self.checkmark.onTap = newValue
        }
        get {
            self.checkmark.onTap
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.question = nil
        self.removeOptions()
    }

    private func setupViews() {
        self.selectionStyle = .none

        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        self.expandButton.addTarget(self, action: #selector(self.didPressExpandButton), for: .touchUpInside)
        self.expandButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.expandButton.setTitle("-", for: .normal)
        self.expandButton.setTitleColor(.black, for: .normal)

        self.label.numberOfLines = 1

        self.optionsStackView.axis = .horizontal
        self.optionsStackView.spacing = 10

        self.stackView.addArrangedSubview(self.expandButton)
        self.stackView.addArrangedSubview(self.label)
        self.stackView.addArrangedSubview(self.scrollView)
        self.stackView.axis = .horizontal
        self.stackView.spacing = 10
        self.stackView.isLayoutMarginsRelativeArrangement = true

        self.contentView.nn_addSubview(self.stackView)
        self.scrollView.nn_addSubview(self.optionsStackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.heightAnchor.constraint(equalTo: container.heightAnchor)
            ]
        }
        self.nn_addSubview(self.checkmark) { (view, container) -> [NSLayoutConstraint] in
            [
                view.heightAnchor.constraint(equalToConstant: 30),
                view.widthAnchor.constraint(equalToConstant: 30),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20)
            ]
        }
    }

    private func updateViews() {
        if let question = self.question, question.children.isEmpty {
            self.expandButton.setTitle(" ", for: .normal)
        }

        switch question?.kind {
        case .dateTime, .variablesToOutput, .size, .grouped, .list, .image:
            self.label.text = self.question?.question
        case .reusable(let filename):
            self.label.text = "Reusable: [\(filename)]"
        case .none:
            self.label.text = nil
        }

        self.removeOptions()
        self.addOptions()

        self.optionsStackView.addArrangedSubview(UIView())
    }

    private func addOptions() {
        for index in self.options.indices {
            let option = self.options[index]

            switch question?.kind {
            case .dateTime, .variablesToOutput, .size, .list, .image, .reusable:
                addTextOptionView(option: option)
            case .grouped:
                if let question = self.question {
                    addGroupOptionView(option: option, question: question)
                }
            case .none:
                break
            }
        }
    }

    private func removeOptions() {
        self.optionsStackView.subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Actions
extension SelectAnswerCell {

    @objc private func didPressExpandButton() {
        self.onExpand?()
    }

}

// MARK: - Text Options
extension SelectAnswerCell {

    private func addTextOptionView(option: Option) {
        let optionView = TextOptionView()
        optionView.title = option.kind.title
        optionView.onTap = { [weak self] in
            self?.onSelectOption?(option)
        }
        self.optionsStackView.addArrangedSubview(optionView)
    }

    func addGroupOptionView(option: Option, question: Question) {
        for child in option.kind.children {
              switch child.kind {
              case .groupedOverride(_, let children):
                children.forEach {
                    addTextOptionView(option: $0)
                }
              default:
                  if let rootOption = question.options.first(where: { $0.kind.children.contains(child) }),
                      case Option.Kind.grouped(_, _, _, _, let options) = rootOption.kind {
                      options.forEach {
                          addTextOptionView(option: $0)
                      }
                  }
              }
          }

          let view = UIView()
          view.backgroundColor = .black
          view.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
          self.optionsStackView.addArrangedSubview(view)
    }
}
