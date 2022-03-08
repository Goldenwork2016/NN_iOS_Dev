//
//  QuestionsTimeCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionsDateTimeCell: QuestionsBaseCell {

    private let scrollView = UIScrollView()

    private let dateContainerStackView = UIStackView()
    private let monthPicker = HorizontalPicker()
    private let dayPicker = HorizontalPicker()
    private let yearPicker = HorizontalPicker()

    private let timeContainerStackView = UIStackView()
    private let hoursStackView = UIStackView()
    private let minutesStackView = UIStackView()
    private let middayStackView = UIStackView()

    private let dateLabel = UILabel()

    private var hour: Int?
    private var minute: Int?
    private var midday: Midday?

    private var dateFormatter: NNDateFormatter {
        guard case .dateTime(let formatter) = self.question?.kind else {
            return NNDateFormatter.default
        }

        return formatter
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.clearAnswers()
        self.scrollView.setContentOffset(.zero, animated: true)
        self.updateNextButton()
    }

    override func getSelectedOptions() -> [Option] {
        guard let oldOption = self.question?.options.first,
            let date = self.getDateTime() else { return [] }

        let dateString = self.dateFormatter.string(from: date)
        let newNarrative = oldOption.narrative + dateString
        let newOption = Option(kind: oldOption.kind, narrative: newNarrative, id: oldOption.id)

        return [newOption]
    }

    private func updateNextButton() {
        let readyToGoNext: Bool

        if self.dateFormatter.containsTime {
            readyToGoNext = self.hour != nil && self.minute != nil && self.midday != nil
        } else {
            readyToGoNext = true
        }

        self.onReadyToGoNext?(readyToGoNext)
    }


    override func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        super.setQuestion(question, isFirstQuestion: isFirstQuestion)

        self.dateContainerStackView.isHidden = !self.dateFormatter.containsDate
        self.timeContainerStackView.isHidden = !self.dateFormatter.containsTime
        updateSelectedDateLabel()
        updateNextButton()
    }

    override func setupViews() {
        super.setupViews()

        self.dateLabel.font = .nn_font(type: .boldOblique, sizeFont: 28)
        self.dateLabel.textColor = .nn_lightBlue
        self.dateLabel.textAlignment = .center
        self.dateLabel.heightAnchor.constraint(equalToConstant: 69).isActive = true
        self.dateLabel.backgroundColor = .white
        self.dateLabel.numberOfLines = 1
        self.dateLabel.minimumScaleFactor = 0.5
        self.dateLabel.adjustsFontSizeToFitWidth = true
        self.dateLabel.adjustsFontForContentSizeCategory = true

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logoTwoRowsDark"))
        logoImageView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        logoImageView.contentMode = .center

        self.dateContainerStackView.axis = .vertical
        self.dateContainerStackView.spacing = 16
        self.dateContainerStackView.clipsToBounds = false

        self.timeContainerStackView.axis = .vertical
        self.timeContainerStackView.spacing = 0

        let timeStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.dateContainerStackView, self.timeContainerStackView, logoImageView])
        timeStackView.axis = .vertical
        timeStackView.spacing = 21
        timeStackView.layoutMargins = .zero
        timeStackView.isLayoutMarginsRelativeArrangement = true
        timeStackView.layoutMargins = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 0)

        addDateViews(to: self.dateContainerStackView)
        addTimeViews(to: self.timeContainerStackView)

        self.scrollView.nn_addSubview(timeStackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor)
            ]
        }

        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.bounces = false

        let rootStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.scrollView])
        rootStackView.axis = .vertical
        rootStackView.spacing = 0
        rootStackView.layoutMargins = .zero

        self.cardView.nn_addSubview(rootStackView)
    }

    private func getDateTime() -> Date? {
        var components = DateComponents()

        if let year = Int(self.yearPicker.selectedItem) {
            components.year = year
        }

        if let monthIndex = Calendar.current.shortMonthSymbols.firstIndex(of: self.monthPicker.selectedItem) {
            components.month = monthIndex + 1
        }

        if let day = Int(self.dayPicker.selectedItem) {
            components.day = day
        }

        if var hour = self.hour,
            let minute = self.minute,
            let midday = self.midday {

            if midday == Midday.pm {
                hour = hour + 12
            }

            components.hour = hour
            components.minute = minute
        }

        guard let date = Calendar.current.date(from: components) else {
            return nil
        }

        return date
    }

    private func clearAnswers() {
        let date = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        let monthsItems = calendar.shortMonthSymbols
        self.monthPicker.setItems(monthsItems)
        if let currentMonth = dateComponents.month,
            currentMonth > 0,
            currentMonth <= monthsItems.count {
            self.monthPicker.selectItem(at: currentMonth - 1, animated: false)
        }

        let countOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 31
        let dayItems = (1...countOfDays).map { String($0) }
        self.dayPicker.setItems(dayItems)
        if let currentDay = dateComponents.day,
            let selectedItemIndex = dayItems.firstIndex(of: String(currentDay)) {
            self.dayPicker.selectItem(at: selectedItemIndex, animated: false)
        }

        let yearItems = (1900...2100).map { String($0) }
        self.yearPicker.setItems(yearItems)
        if let currentYear = dateComponents.year,
            let selectedItemIndex = yearItems.firstIndex(of: String(currentYear)) {
            self.yearPicker.selectItem(at: selectedItemIndex, animated: false)
        }

        resetTimeButtonsToDefaultState(in: self.hoursStackView)
        resetTimeButtonsToDefaultState(in: self.minutesStackView)
        resetTimeButtonsToDefaultState(in: self.middayStackView)

        self.hour = nil
        self.minute = nil
        self.midday = nil
    }
}

// MARK: - Date
extension QuestionsDateTimeCell {

    private func addDateViews(to stackView: UIStackView) {
        let date = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        self.monthPicker.heightAnchor.constraint(equalToConstant: 36).isActive = true
        let monthsItems = calendar.shortMonthSymbols
        self.monthPicker.font = .nn_font(type: .bold, sizeFont: 28)
        self.monthPicker.setItems(monthsItems)
        if let currentMonth = dateComponents.month,
            currentMonth > 0,
            currentMonth <= monthsItems.count {
            self.monthPicker.selectItem(at: currentMonth - 1, animated: false)
        }
        self.monthPicker.onSelect = { [weak self] _ in
            self?.updateDaysPicker()
            self?.updateSelectedDateLabel()
            self?.updateNextButton()
        }
        stackView.addArrangedSubview(self.monthPicker)
        stackView.setCustomSpacing(3, after: self.monthPicker)

        self.dayPicker.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.dayPicker.font = .nn_font(type: .bold, sizeFont: 36)
        let countOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 31
        let dayItems = (1...countOfDays).map { String($0) }
        self.dayPicker.setItems(dayItems)
        if let currentDay = dateComponents.day,
            let selectedItemIndex = dayItems.firstIndex(of: String(currentDay)) {
            self.dayPicker.selectItem(at: selectedItemIndex, animated: false)
        }
        self.dayPicker.onSelect = { [weak self] _ in
            self?.updateSelectedDateLabel()
            self?.updateNextButton()
        }
        stackView.addArrangedSubview(self.dayPicker)
        stackView.setCustomSpacing(3, after: self.dayPicker)

        self.yearPicker.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.yearPicker.font = .nn_font(type: .bold, sizeFont: 32)
        let yearItems = (1900...2100).map { String($0) }
        self.yearPicker.setItems(yearItems)
        if let currentYear = dateComponents.year,
            let selectedItemIndex = yearItems.firstIndex(of: String(currentYear)) {
            self.yearPicker.selectItem(at: selectedItemIndex, animated: false)
        }
        self.yearPicker.onSelect = { [weak self] _ in
            self?.updateDaysPicker()
            self?.updateSelectedDateLabel()
            self?.updateNextButton()
        }
        stackView.addArrangedSubview(self.yearPicker)
        stackView.setCustomSpacing(32, after: self.yearPicker)

        addDateSelector(to: stackView)

        if self.dateFormatter.containsTime {
            addSeparatorView(to: stackView, spacing: 18)
        }

        updateSelectedDateLabel()
    }

    private func addDateSelector(to stackView: UIStackView) {
        let selectorView = UIView()
        stackView.nn_addSubview(selectorView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -16),
                view.widthAnchor.constraint(equalToConstant: 91),
                view.heightAnchor.constraint(equalToConstant: 148)
            ]
        }

        let selectorBackgroundView = UIView()
        selectorBackgroundView.backgroundColor = .white
        selectorBackgroundView.nn_roundAllCorners(radius: .value(16))
        selectorBackgroundView.layer.borderWidth = 1
        selectorBackgroundView.layer.borderColor = UIColor.nn_midGray.cgColor
        selectorView.nn_addSubview(selectorBackgroundView)

        let innnerBorderView = UIView()
        innnerBorderView.layer.borderWidth = 1
        innnerBorderView.layer.borderColor = UIColor.nn_midGray.cgColor
        selectorView.nn_addSubview(innnerBorderView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.heightAnchor.constraint(equalToConstant: 50)
            ]
        }

        stackView.sendSubviewToBack(selectorView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            selectorView.layer.nn_applyShadow()
        }
    }

    private func updateDaysPicker() {
        var components = DateComponents()

        if let year = Int(self.yearPicker.selectedItem) {
            components.year = year
        }

        if let monthIndex = Calendar.current.shortMonthSymbols.firstIndex(of: self.monthPicker.selectedItem) {
            components.month = monthIndex + 1
        }

        let calendar = Calendar.current
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            let numDays = range.count
            let selectedDay = self.dayPicker.selectedItemIndex
            let dayItems = (1...numDays).map { String($0) }
            self.dayPicker.setItems(dayItems)
            self.dayPicker.selectItem(at: min(selectedDay, numDays - 1), animated: false)
        }
    }

    private func updateSelectedDateLabel() {
        guard let date = getDateTime() else {
            self.dateLabel.text = nil
            return
        }

        var dateString = self.dateFormatter.string(from: date)

        if self.hour == nil ||
            self.minute == nil ||
            self.midday == nil {
            dateString = dateString
                .replacingOccurrences(of: " at ", with: "")
                .replacingOccurrences(of: "12:00 a.m.", with: "")
        }

        self.dateLabel.text = dateString
    }
}

// MARK: - Time
extension QuestionsDateTimeCell {

    private func addTimeViews(to stackView: UIStackView) {
        self.hoursStackView.axis = .vertical
        self.hoursStackView.isLayoutMarginsRelativeArrangement = true
        self.hoursStackView.layoutMargins = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
        for verticalIndex in 0...2 {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            for horizontalIndex in 1...4 {
                let button = NNSelectableButton()
                let hour = self.getHour(verticalIndex: verticalIndex, horizontalIndex: horizontalIndex)
                button.tag = hour
                button.title = "\(hour):"
                button.widthAnchor.constraint(equalToConstant: 50).isActive = true
                button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
                button.addTarget(self, action: #selector(self.hourButtonPressed(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }

            self.hoursStackView.addArrangedSubview(stackView)
        }
        stackView.addArrangedSubview(self.hoursStackView)
        stackView.setCustomSpacing(14, after: self.hoursStackView)

        addSeparatorView(to: stackView, spacing: 8)

        self.minutesStackView.axis = .vertical
        self.minutesStackView.isLayoutMarginsRelativeArrangement = true
        self.minutesStackView.layoutMargins = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
        for verticalIndex in 0...2 {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            for horizontalIndex in 0...3 {
                let button = NNSelectableButton()
                let minute = self.getMinute(verticalIndex: verticalIndex, horizontalIndex: horizontalIndex)
                button.tag = minute
                let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"
                button.title = ":\(minuteString)"
                button.widthAnchor.constraint(equalToConstant: 50).isActive = true
                button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
                button.addTarget(self, action: #selector(self.minuteButtonPressed(_:)), for: .touchUpInside)

                stackView.addArrangedSubview(button)
            }
            self.minutesStackView.addArrangedSubview(stackView)
        }

        stackView.addArrangedSubview(self.minutesStackView)
        stackView.setCustomSpacing(14, after: self.minutesStackView)

        addSeparatorView(to: stackView, spacing: 36)

        self.middayStackView.axis = .horizontal
        self.middayStackView.distribution = .fill
        self.middayStackView.spacing = 8
        let firstSpacingMiddayStackView = UIView()
        let lastSpacingMiddayStackView = UIView()
        self.middayStackView.addArrangedSubview(firstSpacingMiddayStackView)
        for midday in Midday.allCases {
            let button = NNSelectableButton()
            button.tag = midday.index
            button.title = midday.value
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.addTarget(self, action: #selector(self.middayButtonPressed(_:)), for: .touchUpInside)

            self.middayStackView.addArrangedSubview(button)
        }
        self.middayStackView.addArrangedSubview(lastSpacingMiddayStackView)
        lastSpacingMiddayStackView.widthAnchor.constraint(equalTo: firstSpacingMiddayStackView.widthAnchor).isActive = true

        stackView.addArrangedSubview(self.middayStackView)
    }

    @objc private func hourButtonPressed(_ sender: UIButton) {
        self.hour = sender.tag

        onTimeButtonClicked(in: self.hoursStackView, selectedButton: sender)
    }

    @objc private func minuteButtonPressed(_ sender: UIButton) {
        self.minute = sender.tag

        onTimeButtonClicked(in: self.minutesStackView, selectedButton: sender)
    }

    @objc private func middayButtonPressed(_ sender: UIButton) {
        self.midday = Midday(rawValue: sender.title(for: .normal) ?? String())

        onTimeButtonClicked(in: self.middayStackView, selectedButton: sender)
    }

    private func getHour(verticalIndex: Int, horizontalIndex: Int) -> Int {
        let hour = verticalIndex * 4 + horizontalIndex
        return hour
    }

    private func getMinute(verticalIndex: Int, horizontalIndex: Int) -> Int {
        let minute = ((verticalIndex * 4) + horizontalIndex) * 5
        return minute
    }

    private func resetTimeButtonsToDefaultState(in stackView: UIStackView) {
        func updateTimeButtonState(in subviews: [UIView]) {
            subviews.forEach {
                if let timeButton = $0 as? NNSelectableButton {
                    timeButton.isSelected = false
                } else {
                    updateTimeButtonState(in: $0.subviews)
                }
            }
        }

        updateTimeButtonState(in: stackView.arrangedSubviews)
    }

    private func onTimeButtonClicked(in stackView: UIStackView, selectedButton: UIButton) {
        func updateTimeButtonState(in subviews: [UIView]) {
            subviews.forEach {
                if let timeButton = $0 as? NNSelectableButton {
                    timeButton.isSelected = timeButton.button === selectedButton
                } else {
                    updateTimeButtonState(in: $0.subviews)
                }
            }
        }

        updateTimeButtonState(in: stackView.arrangedSubviews)
        updateSelectedDateLabel()
        updateNextButton()
    }

    private func addSeparatorView(to stackView: UIStackView, spacing: CGFloat) {
        let separatorView = UIView()
        separatorView.backgroundColor = .nn_midGray

        let separatorViewContainer = UIStackView(arrangedSubviews: [separatorView])
        separatorViewContainer.heightAnchor.constraint(equalToConstant: 2).isActive = true
        separatorViewContainer.isLayoutMarginsRelativeArrangement = true
        separatorViewContainer.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        stackView.addArrangedSubview(separatorViewContainer)
        stackView.setCustomSpacing(spacing, after: separatorViewContainer)
    }
}
