//
//  DateTimeView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 12.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsDateTimeView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let timeCheckmark = CheckmarkButton()
    private let dateCheckmark = CheckmarkButton()

    var onUpdated: VoidClosure?

    var formatter: NNDateFormatter = .default {
        didSet {
            self.dateCheckmark.isSelected = self.formatter.containsDate
            self.timeCheckmark.isSelected = self.formatter.containsTime
        }
    }

    var kind: Question.Kind? {
        return .dateTime(formatter: self.formatter)
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
        self.timeCheckmark.onTap = { [weak self] in
            self?.updateFormatter()
        }
        self.timeCheckmark.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.timeCheckmark.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let timeLabel = UILabel()
        timeLabel.text = "Time"

        let timeStackView = UIStackView(arrangedSubviews: [self.timeCheckmark, timeLabel])
        timeStackView.axis = .horizontal
        timeStackView.spacing = 10

        self.dateCheckmark.onTap = { [weak self] in
            self?.updateFormatter()
        }
        self.dateCheckmark.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.dateCheckmark.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let dateLabel = UILabel()
        dateLabel.text = "Date"

        let dateStackView = UIStackView(arrangedSubviews: [self.dateCheckmark, dateLabel])
        dateStackView.axis = .horizontal
        dateStackView.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [timeStackView, dateStackView])
        stackView.axis = .vertical
        stackView.spacing = 10

        self.nn_addSubview(stackView)
    }

    private func updateFormatter() {
        var formats: [String] = []

        if self.dateCheckmark.isSelected {
            formats.append("EEEE, MMM d, yyyy")
        }

        if self.timeCheckmark.isSelected {
            formats.append("h:mm a")
        }

        self.formatter.updateFormat(formats.joined(separator: " 'at' "))
        self.onUpdated?()
    }
}
