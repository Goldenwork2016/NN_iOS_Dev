//
//  GroupedAnswerTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 28.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

private enum Section: Int, CaseIterable, Identifiable {
    case generalQuestion
    case generalAnswers
    case overrideQuestion

    var id: Int {
       return self.rawValue
    }

    var title: String {
        switch self {
        case .generalQuestion:
            return "General Questions"
        case .generalAnswers:
            return "General Answers"
        case .overrideQuestion:
            return "Override Questions"
        }
    }

    var cellId: Identifier {
        switch self {
        case .generalQuestion, .generalAnswers:
            return AnswerListOptionTableViewCell.className
        case .overrideQuestion:
            return GroupedOverrideQuestionCell.className
        }
    }
}

final class GroupedAnswerTableViewCell: UITableViewCell, AnswerOptionCell {

    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let addNewGeneralOption = UIButton()
    private let addNewGeneralQuestion = UIButton()
    private let addOverrideQuestion = UIButton()
    private let groupBeforeView = IrregularFormView()
    private let groupAfterView = IrregularFormView()
    private let titleTextField = BuilderTextField()

    private(set) var editedOption: Option?
    private var option: Option?

    var onReload: VoidClosure?
    var onEdit: VoidClosure?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var generalQuestions: [Option] {
        guard let option = self.editedOption else { return [] }
        return option.kind.children.filter({ !$0.kind.isParent })
    }
    private var generalAnswers: [Option] {
        guard let option = self.editedOption else { return [] }
        return option.kind.options
    }
    private var overrideQuestions: [Option] {
        guard let option = self.editedOption else { return [] }
        return option.kind.children.filter({ $0.kind.isParent })
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()

        // Workaround for updating all sizes in view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView.updateHeaderViewFrameIfNeeded()
            self?.updateViews()
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.tableView.updateHeaderViewFrameIfNeeded()
    }

    func setOption(_ option: Option) {
        self.option = option
        self.editedOption = option
        self.updateViews()
    }
}

// MARK: - Update Data
extension GroupedAnswerTableViewCell {

    private func replace(option: Option, editedOption: Option, indexPath: IndexPath) {
        guard let rootOption = self.editedOption, case Option.Kind.grouped(title: let title, let beforeGroup, let afterGroup, let children, let options) = rootOption.kind else { return }

        switch indexPath.section {
        case Section.generalQuestion.id:
            if let index = self.generalQuestions.firstIndex(of: option) {
                var updatedChildren = self.generalQuestions
                updatedChildren.remove(at: index)
                updatedChildren.insert(editedOption, at: index)

                self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: updatedChildren + self.overrideQuestions, options: options), narrative: rootOption.narrative, id: rootOption.id)

                self.onEdit?()
            }
        case Section.generalAnswers.id:
            if let index = options.firstIndex(of: option) {
                var updatedOptions = options
                updatedOptions.remove(at: index)
                updatedOptions.insert(editedOption, at: index)

                self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: updatedOptions), narrative: rootOption.narrative, id: rootOption.id)

                self.onEdit?()
            }
        case Section.overrideQuestion.id:
            if let index = self.overrideQuestions.firstIndex(of: option) {
                var updatedChildren = self.overrideQuestions
                updatedChildren.remove(at: index)
                updatedChildren.insert(editedOption, at: index)

                self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: self.generalQuestions + updatedChildren, options: options), narrative: rootOption.narrative, id: rootOption.id)

                self.onEdit?()
            }
        default:
            break
        }
    }

    private func removeOption(at indexPath: IndexPath) {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        switch indexPath.section {
        case Section.generalQuestion.id:
            var updatedChildren = self.generalQuestions
            updatedChildren.remove(at: indexPath.row)
            updatedChildren += self.overrideQuestions

            self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: updatedChildren, options: options), narrative: editedOption.narrative, id: editedOption.id)

            self.updateViews()
            self.onEdit?()
        case Section.generalAnswers.id:
            var updatedOptions = options
            updatedOptions.remove(at: indexPath.row)

            self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: updatedOptions), narrative: editedOption.narrative, id: editedOption.id)

            self.updateViews()
            self.onEdit?()
        case Section.overrideQuestion.id:
            var updatedChildren = self.overrideQuestions
            updatedChildren.remove(at: indexPath.row)
            updatedChildren += self.generalQuestions

            self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: updatedChildren, options: options), narrative: editedOption.narrative, id: editedOption.id)

            self.updateViews()
            self.onEdit?()
        default:
            break
        }
    }

    @objc private func addNewGeneralOptionTapped() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        let option = Option(kind: .text(title: ""), narrative: "", id: UUID().uuidString)
        let updatedGeneralOptions = options + [option]

        self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: updatedGeneralOptions), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
        self.updateViews()
        self.onReload?()
    }

    @objc private func addNewGeneralQuestionTapped() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        let option = Option(kind: .text(title: ""), narrative: "", id: UUID().uuidString)
        let updatedGeneralQuestions = children + [option]

        self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: updatedGeneralQuestions, options: options), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
        self.updateViews()
        self.onReload?()
    }

    @objc private func addOverrideQuestionTapped() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        let option = Option(kind: .groupedOverride(title: "", children: []), narrative: "", id: UUID().uuidString)
        let updatedGeneralQuestions = children + [option]

        self.editedOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: updatedGeneralQuestions, options: options), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
        self.updateViews()
        self.onReload?()
    }

    private func updateEditedIrregularForms() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        self.editedOption = Option(kind: .grouped(title: title, beforeGroup: self.groupBeforeView.updatedNarrative ?? beforeGroup, afterGroup: self.groupAfterView.updatedNarrative ?? afterGroup, children: children, options: options), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
    }

    @objc private func updateGroupTitle() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(title: let title, beforeGroup: let beforeGroup, afterGroup: let afterGroup, children: let children, options: let options) = editedOption.kind else { return }

        self.editedOption = Option(kind: .grouped(title: self.titleTextField.text ?? title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: options), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
    }
}

// MARK: - Getters
extension GroupedAnswerTableViewCell {

    private func getNumberOfSections() -> Int {
        return Section.allCases.count
    }

    private func getNumberOfRows(in section: Int) -> Int {
        switch section {
        case Section.generalQuestion.id:
            return self.generalQuestions.count
        case Section.generalAnswers.id:
            return self.generalAnswers.count
        case Section.overrideQuestion.id:
            return self.overrideQuestions.count
        default:
            return 0
        }
    }

    private func getOption(for indexPath: IndexPath) -> Option? {
        switch indexPath.section {
        case Section.generalQuestion.id:
            return self.generalQuestions[safe: indexPath.row]
        case Section.generalAnswers.id:
            return self.generalAnswers[safe: indexPath.row]
        case Section.overrideQuestion.id:
            return self.overrideQuestions[safe: indexPath.row]
        default:
            return nil
        }
    }

    private func getCellReuseIdentifier(for indexPath: IndexPath) -> String? {
        guard let sectionItem = Section(rawValue: indexPath.section) else {
            return nil
        }

        return sectionItem.cellId
    }

}

// MARK: - UITableViewDataSource
extension GroupedAnswerTableViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.getNumberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getNumberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellReuseIdentifier = self.getCellReuseIdentifier(for: indexPath), let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? AnswerOptionCell else { return UITableViewCell() }

        let option = self.getOption(for: indexPath)

        if let option = option {
            cell.setOption(option)
        }
        cell.onEdit = { [weak self, weak cell] in
            guard let editedOption = cell?.editedOption, let option = option else { return }
            self?.replace(option: option, editedOption: editedOption, indexPath: indexPath)
        }

        if let groupedOverrideQuestionCell = cell as? GroupedOverrideQuestionCell {
            groupedOverrideQuestionCell.onReload = self.onReload
        }

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
}

// MARK: - Setup View
extension GroupedAnswerTableViewCell {

    private func setupViews() {
        setupGroupTitleTextField()
        setupIrregularFormViews()
        setupTableView()
        setupAddButtons()
    }

    private func setupGroupTitleTextField() {
        self.titleTextField.placeholder = "Enter group name"
        self.titleTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateGroupTitle), name: UITextField.textDidChangeNotification, object: self.titleTextField)
    }

    private func setupIrregularFormViews() {
        self.groupBeforeView.title = "Group Before"
        self.groupBeforeView.onChanged = { [weak self] in
            self?.updateEditedIrregularForms()
        }

        self.groupAfterView.title = "Group After"
        self.groupAfterView.onChanged = { [weak self] in
            self?.updateEditedIrregularForms()
        }
    }

    private func setupTableView() {
        let headerViewStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.titleTextField, self.groupBeforeView, self.groupAfterView])
        headerViewStackView.axis = .vertical
        headerViewStackView.spacing = 20

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.isEditing = false
        self.tableView.backgroundColor = .white
        self.tableView.setTableHeaderView(headerView: headerViewStackView)
        self.tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalToConstant: 100)
        self.tableViewHeightConstraint?.isActive = true
        self.tableView.isScrollEnabled = false

        self.tableView.register(AnswerListOptionTableViewCell.self, forCellReuseIdentifier: AnswerListOptionTableViewCell.className)
        self.tableView.register(GroupedOverrideQuestionCell.self, forCellReuseIdentifier: GroupedOverrideQuestionCell.className)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.contentView.nn_addSubview(self.tableView)
    }

    private func setupAddButtons() {
        self.addNewGeneralOption.setImage(UIImage(systemName: "plus"), for: .normal)
        self.addNewGeneralOption.tintColor = .black
        self.addNewGeneralOption.addTarget(self, action: #selector(self.addNewGeneralOptionTapped), for: .touchUpInside)
        self.addNewGeneralOption.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.addNewGeneralOption.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.addNewGeneralQuestion.setImage(UIImage(systemName: "plus"), for: .normal)
        self.addNewGeneralQuestion.tintColor = .black
        self.addNewGeneralQuestion.addTarget(self, action: #selector(self.addNewGeneralQuestionTapped), for: .touchUpInside)
        self.addNewGeneralQuestion.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.addNewGeneralQuestion.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.addOverrideQuestion.setTitle("Add override question", for: .normal)
        self.addOverrideQuestion.setTitleColor(.black, for: .normal)
        self.addOverrideQuestion.tintColor = .black
        self.addOverrideQuestion.addTarget(self, action: #selector(self.addOverrideQuestionTapped), for: .touchUpInside)
        self.addOverrideQuestion.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

}

// MARK: - Update View
extension GroupedAnswerTableViewCell {

    private func updateViews() {
        updateTableView()
        updateIrregularViews()
        updateGrouptitle()
    }

    private func updateGrouptitle() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(let title, beforeGroup: _, afterGroup: _, _, _) = editedOption.kind else { return }

        self.titleTextField.text = title
    }

    private func updateIrregularViews() {
        guard let editedOption = self.editedOption, case Option.Kind.grouped(_, beforeGroup: let beforeGroup, afterGroup: let afterGroup, _, _) = editedOption.kind else { return }

        self.groupBeforeView.setIrregularForm(beforeGroup)
        self.groupAfterView.setIrregularForm(afterGroup)
    }

    private func updateTableView() {
        self.tableView.reloadData()

        let tableHeaderViewHeight: CGFloat = 316
        let numberOfSections = self.getNumberOfSections()

        var height: CGFloat = 0
        let rowHeight: CGFloat = 44 + 44 + 44 + 30 + 10
        let sectionHeaderHeight: CGFloat = 44
        let sectionFooterHeight: CGFloat = 44
        for section in 0...numberOfSections - 1 {
            let numberOfItems = self.getNumberOfRows(in: section)
            switch section {
            case 0, 1:
                height += sectionHeaderHeight + CGFloat(numberOfItems) * rowHeight + sectionFooterHeight
            case 2:
                height += sectionHeaderHeight + sectionFooterHeight
                if numberOfItems > 0 {
                    for row in 0...numberOfItems - 1 {
                        let indexPath = IndexPath(row: row, section: section)
                        if let item = self.getOption(for: indexPath) {
                            let children = item.kind.children
                            let rowHeight: CGFloat = 100 + 44 + CGFloat(children.count) * rowHeight
                            height += rowHeight
                        }
                    }
                }
            default:
                break
            }
        }

        self.tableViewHeightConstraint?.constant = height + tableHeaderViewHeight
    }
}

// MARK: - UITableViewDelegate
extension GroupedAnswerTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionItem = Section(rawValue: section) else {
            return nil
        }

        let label = UILabel()
        label.text = sectionItem.title
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        let stackView = UIStackView()
        stackView.axis = .horizontal

        switch section {
        case Section.generalQuestion.id:
            stackView.addArrangedSubview(self.addNewGeneralQuestion)
            stackView.addArrangedSubview(UIView())
        case Section.generalAnswers.id:
            stackView.addArrangedSubview(self.addNewGeneralOption)
            stackView.addArrangedSubview(UIView())
        case Section.overrideQuestion.id:
            stackView.addArrangedSubview(self.addOverrideQuestion)
            stackView.addArrangedSubview(UIView())
        default:
            break
        }

        footerView.nn_addSubview(stackView)

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
}
