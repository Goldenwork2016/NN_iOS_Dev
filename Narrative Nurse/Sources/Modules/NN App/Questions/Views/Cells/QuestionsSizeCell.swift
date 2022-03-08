//
//  QuestionsSizeCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionsSizeCell: QuestionsBaseCell {

    private var values: [Int: Double] = [:]

    private let valuesLabel = UILabel()
    private let scrollView = UIScrollView()
    private let sizeViewsStackView = UIStackView()
    private var logoContainerViewHeightConstraint: NSLayoutConstraint?

    private var sizeViews: [SizeView] {
        return self.sizeViewsStackView.arrangedSubviews
            .compactMap { $0 as? SizeView }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.values = [:]
        self.valuesLabel.text = nil
        self.sizeViewsStackView.subviews.forEach { $0.removeFromSuperview() }
        self.scrollView.setContentOffset(.zero, animated: true)
        self.onReadyToGoNext?(false)
    }

    override func setupViews() {
        super.setupViews()

        self.valuesLabel.font = .nn_font(type: .boldOblique, sizeFont: 28)
        self.valuesLabel.textColor = .nn_lightBlue
        self.valuesLabel.textAlignment = .center
        self.valuesLabel.heightAnchor.constraint(equalToConstant: 69).isActive = true
        self.valuesLabel.backgroundColor = .white
        self.valuesLabel.numberOfLines = 1
        self.valuesLabel.minimumScaleFactor = 0.5
        self.valuesLabel.adjustsFontSizeToFitWidth = true
        self.valuesLabel.adjustsFontForContentSizeCategory = true

        self.sizeViewsStackView.axis = .vertical
        self.sizeViewsStackView.spacing = 22

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logoTwoRowsDark"))
        logoImageView.contentMode = .center

        let logoContainerView = UIView()
        self.logoContainerViewHeightConstraint = logoContainerView.heightAnchor.constraint(equalToConstant: 160)
        self.logoContainerViewHeightConstraint?.isActive = true

        logoContainerView.nn_addSubview(logoImageView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: 160)
            ]
        }

        let stackViewForScrollView = UIStackView(arrangedSubviews: [self.sizeViewsStackView, logoContainerView])
        stackViewForScrollView.axis = .vertical
        stackViewForScrollView.spacing = 0
        stackViewForScrollView.isLayoutMarginsRelativeArrangement = true
        stackViewForScrollView.layoutMargins = .zero
        stackViewForScrollView.setCustomSpacing(18, after: self.valuesLabel)

        self.scrollView.nn_addSubview(stackViewForScrollView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor)
            ]
        }

        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.bounces = false

        let rootStackView = UIStackView(arrangedSubviews: [self.valuesLabel, self.scrollView])
        rootStackView.axis = .vertical
        rootStackView.spacing = 18
        rootStackView.distribution = .fill

        self.cardView.nn_addSubview(rootStackView)
    }

    override func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        super.setQuestion(question, isFirstQuestion: isFirstQuestion)

        for index in 0...question.options.count - 1 {
            if let option = question.options[safe: index] {
                let sizeView = SizeView(option: option)
                sizeView.onValue = { [weak self] (valueDouble) in
                    self?.updateValue(at: index, value: valueDouble ?? 0)
                    self?.updateValuesLabel()
                }

                self.sizeViewsStackView.addArrangedSubview(sizeView)
            }
        }

        updateValuesLabel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.updateLogoContainerHeight()
        }
    }

    private func updateLogoContainerHeight() {
        let contentHeight = self.scrollView.contentSize.height
        let footerHeight = self.logoContainerViewHeightConstraint?.constant ?? 0
        let tableHeight = self.scrollView.frame.height
        let minimumFooterHeight: CGFloat = 160

        var newFooterHeight: CGFloat
        if contentHeight - footerHeight < tableHeight {
            newFooterHeight = max(tableHeight - contentHeight + footerHeight, minimumFooterHeight)
            assert(newFooterHeight >= minimumFooterHeight)
        } else {
            newFooterHeight = 160
        }

        self.logoContainerViewHeightConstraint?.constant = newFooterHeight
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func updateValuesLabel() {
        self.valuesLabel.text = self.sizeViews
            .map { getNarrative(for: $0) }
            .joined(separator: " ")
    }

    private func getNarrative(for sizeView: SizeView) -> String {
        let addUnitToTheLast = areAllOptionsHaveTheSameUnit()
        var components: [String] = []

        components.append(sizeView.formattedValue)

        if !addUnitToTheLast {
            components.append(sizeView.unit)
        }

        components.append(sizeView.option.narrative)

        if sizeView === self.sizeViews.last, addUnitToTheLast {
            components.append(sizeView.unit)
        }

        return components.filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func areAllOptionsHaveTheSameUnit() -> Bool {
        let units = Set<String>(self.question?.options.compactMap(\.kind.unit) ?? [])
        return units.count <= 1
    }

    private func canGoNext() -> Bool {
        guard let question = self.question else { return false }

        for index in 0...question.options.count - 1 {
            if self.values[index] == nil {
                return false
            }
        }

        return true
    }

    private func updateValue(at index: Int, value: Double) {
        self.values[index] = value

        self.onReadyToGoNext?(self.canGoNext())
    }

    override func getSelectedOptions() -> [Option] {
        guard self.canGoNext() else { return [] }

        return self.sizeViews.map { sizeView -> Option in
            let newNarrative = getNarrative(for: sizeView)
            return Option(kind: sizeView.option.kind, narrative: newNarrative, id: sizeView.option.id)
        }
    }

}
