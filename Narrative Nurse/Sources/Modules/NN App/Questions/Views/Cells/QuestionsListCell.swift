//
//  QuestionsListCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionsListCell: QuestionsBaseCell {

    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var selectedOptions: [Option] = []

    override func prepareForReuse() {
        super.prepareForReuse()

        self.question = nil
        self.tableView.tableFooterView = nil
        self.clearAnswers()
    }

    override func setupViews() {
        super.setupViews()
        self.tableView.backgroundColor = .clear
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.clipsToBounds = true
        self.tableView.bounces = false
        self.tableView.register(OptionsTableViewCell.self, forCellReuseIdentifier: OptionsTableViewCell.className)

        self.cardView.nn_addSubview(self.tableView)
    }

    override func getSelectedOptions() -> [Option] {
        return self.selectedOptions
    }

    override func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        super.setQuestion(question, isFirstQuestion: isFirstQuestion)

        self.tableView.reloadData()

        setNeedsLayout()
        layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.addLogoImage()
        }
    }

    private func addLogoImage() {
        let contentHeight = self.tableView.contentSize.height
        let footerHeight = self.tableView.tableFooterView?.frame.height ?? 0
        let tableHeight = self.tableView.frame.height
        let minimumFooterHeight: CGFloat = 160

        var newFooterHeight: CGFloat
        if contentHeight - footerHeight < tableHeight {
            newFooterHeight = max(tableHeight - contentHeight + footerHeight, minimumFooterHeight)
            assert(newFooterHeight >= minimumFooterHeight)
        } else {
            newFooterHeight = 160
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: newFooterHeight))

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logoTwoRowsDark"))
        logoImageView.contentMode = .center

        footerView.nn_addSubview(logoImageView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: minimumFooterHeight)
            ]
        }

        self.tableView.tableFooterView = footerView
        self.tableView.updateHeaderViewFrameIfNeeded()
    }

    func clearAnswers() {
        self.selectedOptions.removeAll()
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension QuestionsListCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.className) as? OptionsTableViewCell,
            let question = self.question
            else { return UITableViewCell() }

        cell.selectionStyle = .none
        cell.setContent(question: question)
        cell.onOptions = { [weak self] options in
            self?.selectedOptions = options
            self?.onNext?()
        }
        cell.onSelectedOptions = { [weak self] selectedOptions in
            self?.selectedOptions = selectedOptions
            self?.onReadyToGoNext?(!selectedOptions.isEmpty)
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
        return UITableView.automaticDimension
    }

}

// MARK: UITableViewDelegate
extension QuestionsListCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let question = self.question, indexPath.row == 0 else { return 0 }

        return CGFloat(question.options.count * 50)
    }
}
