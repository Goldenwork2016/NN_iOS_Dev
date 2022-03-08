//
//  VariablesToOutputView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsVariablesToOutputView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let stackView = UIStackView()
    private let tableView = UITableView()

    var sequnce: QuestionsSequence?
    var onUpdated: VoidClosure?
    var variables: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var kind: Question.Kind? {
        return .variablesToOutput(variables: self.variables)
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.nn_addSubview(self.tableView)
    }

    private func moveVariable(from startIndexPath: IndexPath, to endIndexPath: IndexPath) {
        guard let option = self.variables[safe: startIndexPath.row],
            let startIndex = self.variables.firstIndex(of: option) else { return }

        self.variables.remove(at: startIndex)
        self.variables.insert(option, at: endIndexPath.row)
        self.onUpdated?()
    }

    private func removeVariable(at indexPath: IndexPath) {
        self.variables.remove(at: indexPath.row)
        self.onUpdated?()
    }
}

// MARK: - Actions
extension SettingsVariablesToOutputView {

    @objc private func addNewVariable() {
        var allVariables: [String] = []

        func findVariables(in questions: [Question]) {
            for item in questions {
                if let variable = item.outputToVariable, !variable.isEmpty {
                    allVariables.append(variable)
                }
                findVariables(in: item.children)
            }
        }

        findVariables(in: self.sequnce?.questions ?? [])

        NNDropDown.show(anchor: self, items: allVariables) { [weak self] (_, selectedVariable) in
            self?.variables.append(selectedVariable)
            self?.onUpdated?()
        }
    }

    @objc private func toggleEdit() {
        self.tableView.isEditing.toggle()

        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension SettingsVariablesToOutputView: UITableViewDelegate {

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
        let addNewButton = UIButton()
        if #available(iOS 13.0, *) {
            addNewButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        addNewButton.tintColor = .black
        addNewButton.addTarget(self, action: #selector(self.addNewVariable), for: .touchUpInside)
        addNewButton.widthAnchor.constraint(equalToConstant: 44).isActive = true

        let addNewStackView = UIStackView(arrangedSubviews: [addNewButton, UIView()])
        addNewStackView.axis = .horizontal

        let container = UIView()
        container.backgroundColor = .white
        container.nn_addSubview(addNewStackView, layoutConstraints: UIView.nn_constraintsCoverFull)

        return container
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }

}

// MARK: - UITableViewDataSource
extension SettingsVariablesToOutputView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.variables.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.className)

        cell.textLabel?.text = self.variables[indexPath.row]
        cell.editingAccessoryView = nil

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.removeVariable(at: indexPath)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveVariable(from: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
