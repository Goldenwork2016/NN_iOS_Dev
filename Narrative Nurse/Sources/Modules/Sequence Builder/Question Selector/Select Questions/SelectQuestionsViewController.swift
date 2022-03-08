//
//  SelectQuestionsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class SelectQuestionsViewController: BaseQuestionSelectorViewController {

    let selectQuestionsViewModel: SelectQuestionsViewModel
    var onSelect: (([Question]) -> Void)?

    init(selectQuestionsViewModel: SelectQuestionsViewModel) {
        self.selectQuestionsViewModel = selectQuestionsViewModel

        super.init(viewModel: selectQuestionsViewModel)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        self.title = "Select Questions"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(onSubmit))
    }

    @objc private func onCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func onSubmit() {
        self.onSelect?(self.selectQuestionsViewModel.selectedQuestions)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? SelectAnswerCell,
            let question = self.viewModel.getQuestion(at: indexPath) {
            cell.isQuestionSelected = self.selectQuestionsViewModel.isQuestionSelected(question)
            cell.onSelectQuestion = { [weak self] in
                self?.selectQuestionsViewModel.switchSelectonState(for: question)
            }
            cell.isCheckMarkHidden = false
        }

        return cell
    }
}
