//
//  GroupedOverrideQuestionCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 30.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class GroupedOverrideQuestionCell: UITableViewCell, AnswerOptionCell {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let titleTextField = BuilderTextField()
    private let addNewButton = UIButton()

    private var option: Option?
    var editedOption: Option?

    var onEdit: VoidClosure?
    var onReload: VoidClosure?

    private var tableViewHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOption(_ option: Option) {
        self.option = option
        self.editedOption = self.option
        self.updateViews()
    }

    private func setupViews() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.isEditing = false
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundColor = .white
        self.tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalToConstant: 100)
        self.tableViewHeightConstraint?.isActive = true

        self.tableView.register(AnswerListOptionTableViewCell.self, forCellReuseIdentifier: AnswerListOptionTableViewCell.className)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.contentView.nn_addSubview(self.tableView)

        if #available(iOS 13.0, *) {
            self.addNewButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        self.addNewButton.tintColor = .black
        self.addNewButton.addTarget(self, action: #selector(self.addNewOption), for: .touchUpInside)
        self.addNewButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.addNewButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.titleTextField.placeholder = "Title"
        self.titleTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.titleTextField.addTarget(self, action: #selector(self.onTitleTextFieldChanged), for: .editingChanged)
    }

    private func updateViews() {
        self.tableView.reloadData()

        guard let option = self.editedOption, case Option.Kind.groupedOverride(let title, let children) = option.kind else { return }

        self.titleTextField.text = title

        let rowHeight: CGFloat = 44 + 44 + 30 + 10
        let height: CGFloat = 100 + 44 + CGFloat(children.count) * rowHeight

        self.tableViewHeightConstraint?.constant = height
    }

    private func deleteOption(at indexPath: IndexPath) {
        guard let editedOption = self.editedOption, case Option.Kind.groupedOverride(let title, let children) = editedOption.kind else { return }

        var updatedChildren = children
        updatedChildren.remove(at: indexPath.row)
        self.editedOption = Option(kind: .groupedOverride(title: title, children: updatedChildren), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
        self.updateViews()
    }

    private func replace(option: Option, editedOption: Option) {
        guard let rootOption = self.editedOption,
            case Option.Kind.groupedOverride(let title, let children) = rootOption.kind,
            let index = children.firstIndex(where: { $0.id == option.id })
            else { return }

        var updatedChildren = children
        updatedChildren.remove(at: index)
        updatedChildren.insert(editedOption, at: index)

        self.editedOption = Option(kind: .groupedOverride(title: title, children: updatedChildren), narrative: rootOption.narrative, id: rootOption.id)

        self.onEdit?()
    }

    private func numberOfSections() -> Int {
        return 1
    }

    private func numberOfRows(in section: Int) -> Int {
        guard let option = self.editedOption, case Option.Kind.groupedOverride(_, let options) = option.kind else { return 0 }

        return options.count
    }

    private func item(for indexPath: IndexPath) -> Option? {
        guard let option = self.editedOption, case Option.Kind.groupedOverride(_, let options) = option.kind else { return nil }
        return options[safe: indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension GroupedOverrideQuestionCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnswerListOptionTableViewCell.className) as? AnswerOptionCell else { return UITableViewCell() }

        let option = self.item(for: indexPath)

        if let option = option {
            cell.setOption(option)
        }
        cell.onEdit = { [weak self, weak cell] in
            guard let editedOption = cell?.editedOption, let option = option else { return }
            self?.replace(option: option, editedOption: editedOption)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.deleteOption(at: indexPath)
        default:
            break
        }
    }
}

// MARK: - UITableViewDelegate
extension GroupedOverrideQuestionCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Override Question"
        let answersLabel = UILabel()
        answersLabel.text = "Override Answers"

        let stackView = UIStackView(arrangedSubviews: [label, self.titleTextField, answersLabel])
        stackView.axis = .vertical
        stackView.setCustomSpacing(10, after: self.titleTextField)

        return stackView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let stackView = UIStackView(arrangedSubviews: [self.addNewButton, UIView()])
        stackView.axis = .horizontal

        return stackView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
}

// MARK: - Actions
extension GroupedOverrideQuestionCell {

    @objc private func onTitleTextFieldChanged() {
        guard let editedOption = self.editedOption, case Option.Kind.groupedOverride(let title, let options) = editedOption.kind else { return }

        self.editedOption = Option(kind: .groupedOverride(title: self.titleTextField.text ?? title, children: options), narrative: editedOption.narrative, id: editedOption.id)
        self.onEdit?()
    }

    @objc private func addNewOption() {
        guard let editedOption = self.editedOption, case Option.Kind.groupedOverride(let title, let children) = editedOption.kind else { return }
        let option = Option(kind: .text(title: ""), narrative: "", id: UUID().uuidString)

        let updatedChildren = children + [option]
        self.editedOption = Option(kind: .groupedOverride(title: title, children: updatedChildren), narrative: editedOption.narrative, id: editedOption.id)

        self.onEdit?()
        self.updateViews()
        self.onReload?()
    }
}
