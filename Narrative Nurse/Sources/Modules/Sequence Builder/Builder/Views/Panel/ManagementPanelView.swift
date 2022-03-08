//
//  ManagementPanelView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 21.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class ManagementPanelView: UIView {

    private let questionLabel = UILabel()
    private let questionViewOnlyLabel = UILabel()
    private let questionTypeLabel = UILabel()
    private let reverseToLoadButton = BuilderButton()

    private let questionTextField = BuilderTextField()

    private var panelViews: [PanelView] = [SettingsView(), RuleView(), AppendView(), AnswersView()]

    var settingsView: SettingsView? {
        return self.panelViews[safe: 0] as? SettingsView
    }

    private var ruleView: RuleView? {
        return self.panelViews[safe: 1] as? RuleView
    }

    private var appendView: AppendView? {
        return self.panelViews[safe: 2] as? AppendView
    }

    private var answersView: AnswersView? {
        return self.panelViews[safe: 3] as? AnswersView
    }

    private lazy var segmentedController: UISegmentedControl = {
        let items = self.panelViews.compactMap { $0.title }
        return UISegmentedControl(items: items)
    }()

    private var selectedIndex: Int = 3 {
        didSet {
            self.answersView?.scrollToTop()
            self.panelViews.forEach({ $0.endEditing(true); $0.isHidden = true })
            self.panelViews[safe: self.selectedIndex]?.isHidden = false
        }
    }

    private var displayObject: PanelDisplayObject?

    var editedQuestion: Question? {
        guard let oldQuestion = self.displayObject?.question else { return nil }

        return Question(id: oldQuestion.id,
                        question: self.questionTextField.text ?? oldQuestion.question,
                        narrative: self.appendView?.narrative,
                        outputToVariable: self.settingsView?.outputToVariable,
                        kind: self.settingsView?.kind ?? oldQuestion.kind,
                        options: self.answersView?.options ?? oldQuestion.options,
                        rule: self.ruleView?.rule ?? oldQuestion.rule,
                        children: oldQuestion.children)
    }

    var onPresent: ((UIAlertController) -> Void)?
    var onPresentFileSelector: ((SequenceFileType, @escaping URLClosure) -> Void)?
    var onUpdated: VoidClosure?
    var onReverse: VoidClosure?
    var onSelectAnswer: (( _ closure: @escaping ((Question, Option) -> Void) ) -> Void)? {
        set {
            self.ruleView?.onSelectAnswer = newValue
        }
        get {
            return self.ruleView?.onSelectAnswer
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    func setDisplayObject(displayObject: PanelDisplayObject) {
        self.displayObject = displayObject

        self.updateViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1

        self.questionLabel.text = "Question"
        self.questionLabel.textColor = .black

        self.questionViewOnlyLabel.text = "[View Only]"
        self.questionViewOnlyLabel.textColor = .black

        self.questionTypeLabel.text = "Type"
        self.questionTypeLabel.textColor = .black
        self.questionTypeLabel.textAlignment = .right

        self.reverseToLoadButton.setTitle("Reverse", for: .normal)
        self.reverseToLoadButton.addTarget(self, action: #selector(self.onClickReverseToLoad), for: .touchUpInside)
        self.reverseToLoadButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let questionTitleStackView = UIStackView(arrangedSubviews: [self.questionLabel, self.questionViewOnlyLabel, self.questionTypeLabel])
        questionTitleStackView.spacing = 10
        questionTitleStackView.axis = .horizontal

        self.questionTextField.placeholder = "Enter question here"
        self.questionTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.questionTextField.delegate = self

        self.segmentedController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        self.segmentedController.selectedSegmentIndex = self.selectedIndex
        self.segmentedController.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let panelView = UIView()
        self.panelViews.forEach({ panelView.nn_addSubview($0) })
        self.panelViews.forEach({ $0.onPresent = { [weak self] in self?.onPresent?($0) } })
        self.panelViews.forEach({ $0.onUpdated = { [weak self] in self?.onUpdated?() } })
        self.panelViews.forEach {
            $0.onPresentFileSelector = { [weak self] (filetype, closure) in
                self?.onPresentFileSelector?(filetype, closure)
            }
        }
        panelView.setContentHuggingPriority(.defaultLow, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [questionTitleStackView, self.reverseToLoadButton, self.questionTextField, self.segmentedController, panelView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        self.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
            ]
        }
    }

    private func updateViews() {
        let isEditable = self.displayObject?.isEditable ?? false

        self.panelViews.forEach { $0.isUserInteractionEnabled = isEditable }

        self.questionTypeLabel.text = self.displayObject?.question?.kind.title
        self.questionTextField.text = self.displayObject?.question?.question
        self.questionTextField.isEnabled = isEditable
        self.questionViewOnlyLabel.isHidden = isEditable
        self.reverseToLoadButton.isHidden = self.displayObject?.canReverse ?? false

        if let displayObject = self.displayObject {
            self.panelViews.forEach { $0.setDisplayObject(displayObject: displayObject) }
        }

    }
}

extension ManagementPanelView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        onUpdated?()
    }

}

// MARK: - Actions
extension ManagementPanelView {

    @objc private func segmentChanged(_ segmentedController: UISegmentedControl) {
        self.selectedIndex = segmentedController.selectedSegmentIndex
    }

    @objc private func onClickReverseToLoad() {
        self.onReverse?()
    }
}
