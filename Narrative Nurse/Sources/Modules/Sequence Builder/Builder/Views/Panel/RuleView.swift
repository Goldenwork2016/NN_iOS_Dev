//
//  RuleView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import Expression
import NNCore

private enum Operator: Equatable {
    static let supportedToAdd: [Operator] = [.and, .or, .not, .openBracket, .closeBracket, .true]
    static let supportedToRead: [Operator] = [.isSelected(questionId: "", optionId: ""), .and, .or, .not, .openBracket, .closeBracket, .true, .false]

    case and
    case or
    case not
    case openBracket
    case closeBracket
    case `true`
    case `false`
    case isSelected(questionId: Identifier, optionId: Identifier)

    var code: String {
        switch self {
        case .and:
            return "&&"
        case .or:
            return "||"
        case .not:
            return "!"
        default:
            return self.title
        }
    }

    var title: String {
        switch self {
        case .and:
            return "AND"
        case .or:
            return "OR"
        case .not:
            return "NOT"
        case .openBracket:
            return "("
        case .closeBracket:
            return ")"
        case .true:
            return "true"
        case .false:
            return "false"
        case .isSelected(questionId: let questionId, optionId: let optionId):
            return "isSelected(\'\(questionId)\',\'\(optionId)\')"
        }
    }

    init?(title: String) {
        guard let element = Operator.supportedToRead.first(where: { $0.title == title }) else {
            return nil
        }

        self = element
    }
}

final class RuleView: PanelView {

    override var title: String {
        return "Rule"
    }

    private let ruleLabel = UILabel()
    private let tableView = UITableView()
    private let operatorButton = BuilderButton()
    private let questionAnswerButton = BuilderButton()

    private var cachedQuestions: [Identifier: Question] = [:]

    private var operators: [Operator] = [] {
        didSet {
            self.ruleLabel.text = self.rule
            self.tableView.reloadData()
        }
    }

    var rule: String? {
        return self.operators.map(\.code).joined(separator: " ")
    }
    var onSelectAnswer: (( _ closure: @escaping ((Question, Option) -> Void) ) -> Void)?

    override func setupViews() {
        self.ruleLabel.numberOfLines = 0
        self.ruleLabel.font = .systemFont(ofSize: 14)
        self.operatorButton.setTitle("Operator", for: .normal)
        self.operatorButton.addTarget(self, action: #selector(self.chooseOperator(_:)), for: .touchUpInside)

        self.questionAnswerButton.setTitle("Question/Answer", for: .normal)
        self.questionAnswerButton.addTarget(self, action: #selector(self.chooseQestionAnswer(_:)), for: .touchUpInside)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let stackView = UIStackView(arrangedSubviews: [self.ruleLabel, self.tableView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        self.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
        }
    }

    override func updateViews() {
        self.operators.removeAll()

        guard let originalRule = self.question?.rule.replacingOccurrences(of: " ", with: ""), !originalRule.isEmpty  else {
            return
        }

        var rule = originalRule
        var operatorRanges: [Range<String.Index>: Operator] = [:]

        // form a ranges if `isSelected` function
        let selectedFuntionPrefix = "isSelected('"
        let selectedFuntionEnd = "')"
        while let paramsInString = rule.slice(from: selectedFuntionPrefix, to: selectedFuntionEnd) {
            let paramsParsed = paramsInString.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "'", with: "")
                .split(separator: ",")
                .map { String($0) }

            if paramsParsed.count == 2 {
                let option = Operator.isSelected(questionId: paramsParsed[0], optionId: paramsParsed[1])
                originalRule.ranges(of: option.code)
                    .forEach { operatorRanges[$0] = option }
                rule = rule.replacingOccurrences(of: option.code, with: "")
            }
        }

        // form a ranges of others elements
        for item in Operator.supportedToRead {
            originalRule.ranges(of: item.code)
                .filter { newRange in
                    return operatorRanges.keys.filter { $0.overlaps(newRange) }.isEmpty
                }
                .forEach { operatorRanges[$0] = item }
            rule = rule.replacingOccurrences(of: item.code, with: "")
        }

        operatorRanges.keys
            .sorted(by: { $0.lowerBound < $1.lowerBound })
            .forEach {
                if let o = operatorRanges[$0] {
                    self.operators.append(o)
                }
        }
    }

    private func moveOption(from startIndexPath: IndexPath, to endIndexPath: IndexPath) {
        guard let option = self.operators[safe: startIndexPath.row],
            let startIndex = self.operators.firstIndex(of: option) else { return }

        self.operators.remove(at: startIndex)
        self.operators.insert(option, at: endIndexPath.row)

        self.onUpdated?()
    }

    private func removeOption(at indexPath: IndexPath) {
        self.operators.remove(at: indexPath.row)

        self.onUpdated?()
    }
}

// MARK: - Actions
extension RuleView {

    @objc private func chooseOperator(_ button: UIButton) {
        NNDropDown.show(anchor: button, items: Operator.supportedToAdd.map(\.title)) { [weak self] (_, selectedValue) in
            guard let o = Operator(title: selectedValue) else {
                return
            }
            self?.operators.append(o)
            self?.onUpdated?()
        }
    }

    @objc private func chooseQestionAnswer(_ button: UIButton) {
        guard let question = self.question,
            let sequence = self.sequence else {
                return
        }

        if let parentQuestion = sequence.findParentQuestion(for: question) {
            var elements = parentQuestion.options.compactMap { "[Parent Answer] \($0.kind.title ?? "")" }
            elements.append("Browse")
            NNDropDown.show(anchor: button, items: elements) { [weak self] (_, selectedValue) in
                if let index = elements.firstIndex(of: selectedValue),
                    let option = parentQuestion.options[safe: index] {
                    let o = Operator.isSelected(questionId: parentQuestion.id, optionId: option.id)
                    self?.operators.append(o)
                    self?.onUpdated?()
                } else {
                    self?.showBrowse()
                }
            }
        } else {
            self.showBrowse()
        }
    }

    private func showBrowse() {
        self.onSelectAnswer?({ [weak self] (question, option) in
            let o = Operator.isSelected(questionId: question.id, optionId: option.id)
            self?.operators.append(o)
            self?.onUpdated?()
        })
    }

    @objc private func toggleEdit() {
        self.tableView.isEditing.toggle()

        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension RuleView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.tableView.isEditing ? "Done" : "Rearrange"
        let button = UIButton()
        button.setTitleColor(.nn_blue, for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(self.toggleEdit), for: .touchUpInside)

        let headerView = UIView()
        headerView.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [UIView(), button])
        stackView.axis = .horizontal

        headerView.nn_addSubview(stackView)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let buttonsStackView = UIStackView(arrangedSubviews: [self.operatorButton, self.questionAnswerButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 10

        let container = UIView()
        container.backgroundColor = .white
        container.nn_addSubview(buttonsStackView, layoutConstraints: UIView.nn_constraintsCoverFull)

        return container
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }

}

// MARK: - UITableViewDataSource
extension RuleView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operators.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        let item = operators[indexPath.row]
        if case .isSelected(let questionId, let optionId) = item {
            let question = self.sequence?.findQuestion(with: questionId)
            let option = question?.options.first(where: { $0.id == optionId })
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)
            cell.textLabel?.text = question?.question ?? questionId
            cell.detailTextLabel?.text = option?.kind.title ?? optionId
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.className)
            cell.textLabel?.text = item.title
        }
        cell.editingAccessoryView = nil
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.removeOption(at: indexPath)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveOption(from: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
