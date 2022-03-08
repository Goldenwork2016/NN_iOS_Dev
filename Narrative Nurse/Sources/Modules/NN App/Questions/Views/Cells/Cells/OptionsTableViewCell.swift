//
//  OptionsTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 25.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class OptionsTableViewCell: UITableViewCell {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private var options: [Option] = []
    private var selectedOptions: [Option] = []
    private var multiSelection: Bool = false

    var onOptions: (([Option]) -> Void)?
    var onSelectedOptions: (([Option]) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectedOptions.removeAll()
        self.onSelectedOptions?(self.selectedOptions)
        self.tableView.reloadData()
    }

    private func setupViews() {
        self.backgroundColor = .clear

        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false
        self.tableView.rowHeight = 50
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.clipsToBounds = false
        self.tableView.bounces = false
        self.tableView.backgroundColor = .clear
        self.tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.className)

        let stackView = UIStackView(arrangedSubviews: [self.tableView])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        self.contentView.nn_addSubview(stackView)
    }

    func setContent(question: Question) {
        self.options = question.options

        if case Question.Kind.list(let multiSelection) = question.kind {
            self.multiSelection = multiSelection
        }

        self.tableView.reloadData()
    }

    private func selected(at indexPath: IndexPath) {
        guard let option = self.options[safe: indexPath.row] else { return }

        if !self.multiSelection || option.kind.isNone {
            self.selectedOptions.removeAll()
            self.selectedOptions.append(option)
            self.tableView.reloadData()
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] (_) in
                self?.onOptions?([option])
            }
        } else {
            if self.selectedOptions.contains(where: { $0.kind.isNone }) {
                self.selectedOptions.removeAll()
                self.selectedOptions.append(option)
                self.onSelectedOptions?(self.selectedOptions)
            } else if self.selectedOptions.contains(option) {
                self.selectedOptions.removeAll(where: { $0.id == option.id })
                self.onSelectedOptions?(self.selectedOptions)
            } else {
                self.selectedOptions.append(option)
                self.onSelectedOptions?(self.selectedOptions)
            }
            self.tableView.reloadData()
        }
    }

    private func isSelected(index: Int) -> Bool {
        guard let option = self.options[safe: index] else {
            return false
        }

        return self.selectedOptions.contains(option)
    }

}

// MARK: - UITableViewDataSource
extension OptionsTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.className) as? OptionTableViewCell,
            let option = self.options[safe: indexPath.row]
            else { return UITableViewCell() }
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1)
        cell.selectionStyle = .none
        cell.setContent(title: option.kind.title, isSelected: self.isSelected(index: indexPath.row), isFirst: isFirst, isLast: isLast, isNextCellSelected: self.isSelected(index: indexPath.row + 1))
        cell.onSelected = { [weak self] in
            self?.selected(at: indexPath)
        }

        return cell
    }
}

// MARK: UITableViewDelegate
extension OptionsTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected(at: indexPath)
    }
}
