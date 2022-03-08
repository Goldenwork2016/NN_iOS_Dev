//
//  QuestionsGroupedCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 15.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore
import BetterSegmentedControl

final class QuestionsGroupedCell: QuestionsBaseCell {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var groupQuestionConverter: GroupQuestionConverter?
    private var subsections: [Int: Subsection] = [:]

    override func prepareForReuse() {
        super.prepareForReuse()

        self.question = nil
        self.tableView.scrollRectToVisible(.zero, animated: false)
        self.clearAnswers()
    }

    override func setupViews() {
        super.setupViews()
        self.tableView.backgroundColor = .nn_lightGray
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.clipsToBounds = true
        self.tableView.bounces = false
        self.tableView.register(GroupedOptionTableViewCell.self, forCellReuseIdentifier: GroupedOptionTableViewCell.className)
        self.tableView.contentInset = .init(top: 21, left: 0, bottom: 0, right: 0)

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logoTwoRowsDark"))
        logoImageView.contentMode = .center
        logoImageView.frame = .init(x: 0, y: 0, width: self.tableView.frame.width, height: 160)
        self.tableView.tableFooterView = logoImageView

        self.cardView.nn_addSubview(self.tableView)
    }

    override func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        self.groupQuestionConverter = GroupQuestionConverter(question: question)

        super.setQuestion(question, isFirstQuestion: isFirstQuestion)

        self.tableView.reloadData()

        setNeedsLayout()
        layoutIfNeeded()
    }

    override func getSelectedOptions() -> [Option] {
        guard let option = self.groupQuestionConverter?.nextButtonPressed() else { return [] }

        return [option]
    }

    func clearAnswers() {
        self.subsections.removeAll()
        self.groupQuestionConverter?.clearAnswers()
        self.tableView.reloadData()
        self.onReadyToGoNext?(false)
    }

    private func presentAlertController(for option: Option, anchorView: UIView) {
        let offset: NNDropDown.Offset = .bottom(value: anchorView.plainView.bounds.height)

        switch option.kind {
        case .groupedOverride(_, let children):
            let items = children.compactMap(\.kind.title)
            NNDropDown.show(anchor: anchorView, items: items, offset: offset) { (index, _) in
                self.optionSelected(parentOption: option, childOption: children[index])
            }
        default:
            if let rootOption = self.question?.options.first(where: { $0.kind.children.contains(option) }),
               case Option.Kind.grouped(_, _, _, _, let options) = rootOption.kind {
                let items = options.compactMap(\.kind.title)
                NNDropDown.show(anchor: anchorView, items: items, offset: offset) { (index, _) in
                    self.optionSelected(parentOption: option, childOption: options[index])
                }
            }
        }
    }

    private func optionSelected(parentOption: Option, childOption: Option) {
        self.groupQuestionConverter?.optionSelected(parentOption: parentOption, childOption: childOption)
        self.tableView.reloadData()
        let readyToGoNext = self.groupQuestionConverter?.hasSelectedOptions ?? false
        self.onReadyToGoNext?(readyToGoNext)
    }

    private func isNextOptionSelected(at indexPath: IndexPath, currentOption: Option) -> Bool {
        let children = getOptionsForCurrentSubsection(in: indexPath.section)

        let isNextSelected: Bool

        if let nextOption = children[safe: indexPath.row + 1], self.groupQuestionConverter?.getSelectedOption(for: nextOption) != nil {
            isNextSelected = true
        } else {
            isNextSelected = false
        }

        return isNextSelected
    }
}

// MARK: - UITableViewDataSource
extension QuestionsGroupedCell: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.question?.options.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getOptionsForCurrentSubsection(in: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let children = getOptionsForCurrentSubsection(in: indexPath.section)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupedOptionTableViewCell.className) as? GroupedOptionTableViewCell,
              let option = children[safe: indexPath.row]
        else { return UITableViewCell() }

        let isLast = indexPath.row == (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1)
        let selectedOption = self.groupQuestionConverter?.getSelectedOption(for: option)
        let isNextSelected = isNextOptionSelected(at: indexPath, currentOption: option)
        cell.setContent(title: option.kind.title, selectedValue: selectedOption?.kind.title, isLast: isLast, isNextCellSelected: isNextSelected)

        cell.onSelected = { [weak self] in
            self?.presentAlertController(for: option, anchorView: cell.containerView)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isLastSection = section == self.numberOfSections(in: tableView) - 1
        return isLastSection ? 0 : 42
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.question?.options[safe: section]?.kind.title
        let label = UILabel()
        label.text = title
        label.font = .nn_font(type: .boldOblique, sizeFont: 28)
        label.textAlignment = .center
        label.textColor = .white
        let titleGradientView = label.nn_wrappedWithGradientView(contentMargins: .init(top: 0, left: 20, bottom: 0, right: 20))
        titleGradientView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let containerView = UIView()
        containerView.backgroundColor = .white

        let backgroundImageView = UIView()
        containerView.nn_addSubview(backgroundImageView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 1)
            ]
        }

        let segments = LabelSegment.segments(withTitles: Subsection.allCases.map(\.title),
                                              numberOfLines: 1,
                                              normalBackgroundColor: .nn_lightGray,
                                              normalFont: .nn_font(type: .bold, sizeFont: 21),
                                              normalTextColor: .nn_lightBlue,
                                              selectedFont: .nn_font(type: .bold, sizeFont: 21),
                                              selectedTextColor: .nn_orange)
        let segmentedControllerOptions: [BetterSegmentedControl.Option] = [.cornerRadius(18),
                                                                           .indicatorViewBorderColor(.nn_midGray),
                                                                           .indicatorViewBorderWidth(1),
                                                                           .indicatorViewBackgroundColor(.white),
                                                                           .backgroundColor(.nn_lightGray),
                                                                           .animationDuration(0.2),
                                                                           .indicatorViewInset(0),
                                                                           .animationSpringDamping(0.75)]
        let segmentedController = BetterSegmentedControl(frame: .zero, segments: segments, index: self.getSubsection(for: section).rawValue, options: segmentedControllerOptions)
        segmentedController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedController.tag = section

        containerView.nn_addSubview(segmentedController) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 43),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -43),
                view.heightAnchor.constraint(equalToConstant: 36),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -4)
            ]
        }

        let segmentShadowView = UIView(frame: .init(x: -40, y: 0, width: self.frame.width, height: 36))
        segmentShadowView.transform = segmentShadowView.transform.rotated(by: .pi)
        segmentedController.insertSubview(segmentShadowView, belowSubview: segmentedController.indicatorView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) { [weak self] in
            backgroundImageView.layer.borderWidth = 1
            backgroundImageView.layer.borderColor = UIColor.nn_midGray.cgColor
            segmentShadowView.layer.nn_applyShadow(color: UIColor.black.withAlphaComponent(0.2), blur: 5)

            // Add shadow only if first item is not selected
            if let firstOption = self?.getOptionsForCurrentSubsection(in: section).first, self?.groupQuestionConverter?.getSelectedOption(for: firstOption) == nil {
                containerView.layer.nn_applyShadow()
            }
        }

        let leftSeparatorView = UIView()
        leftSeparatorView.backgroundColor = .nn_midGray
        leftSeparatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let rightSeparatorView = UIView()
        rightSeparatorView.backgroundColor = .nn_midGray
        rightSeparatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let containerStackView = UIStackView(arrangedSubviews: [containerView])
        containerStackView.axis = .horizontal
        containerStackView.distribution = .fill
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStackView.heightAnchor.constraint(equalToConstant: 67).isActive = true
        containerStackView.isHidden = getOptions(subsection: .allTheSame, section: section).isEmpty

        let stackView = UIStackView(arrangedSubviews: [titleGradientView, containerStackView])
        stackView.axis = .vertical

        return stackView
    }
}

// MARK: - UITableViewDelegate
extension QuestionsGroupedCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - Subsections
extension QuestionsGroupedCell {

    enum Subsection: Int, CaseIterable {
        case allTheSame
        case individual

        var title: String {
            switch self {
            case .allTheSame:
                return "All the same"
            case .individual:
                return "Individual"
            }
        }
    }

    private func getSubsection(for section: Int) -> Subsection {
        return self.subsections[section] ?? getDefaultSubsection(in: section)
    }

    private func getOptions(subsection: Subsection, section: Int) -> [Option] {
        guard let rootOption = self.question?.options[safe: section],
              case Option.Kind.grouped(_, _, _, let children, _) = rootOption.kind else {
            return []
        }

        switch subsection {
        case .allTheSame:
            return children.filter { option in
                if case Option.Kind.groupedOverride = option.kind {
                    return true
                } else {
                    return false
                }
            }
        case .individual:
            return children.filter { option in
                if case Option.Kind.groupedOverride = option.kind {
                    return false
                } else {
                    return true
                }
            }
        }
    }

    private func getOptionsForCurrentSubsection(in section: Int) -> [Option] {
        let segmentState = getSubsection(for: section)
        return getOptions(subsection: segmentState, section: section)
    }

    @objc private func segmentChanged(_ segmentedController: BetterSegmentedControl) {
        let section = segmentedController.tag
        self.subsections[section] = Subsection(rawValue: segmentedController.index) ?? getDefaultSubsection(in: section)
        self.tableView.reloadData()
    }

    private func getDefaultSubsection(in section: Int) -> Subsection {
        return getOptions(subsection: .allTheSame, section: section).isEmpty ? .individual : .allTheSame
    }

}
