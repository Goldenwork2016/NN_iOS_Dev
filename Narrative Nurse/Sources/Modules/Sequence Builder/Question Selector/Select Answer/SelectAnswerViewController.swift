//
//  SelectAnswerViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SelectAnswerViewController: BaseQuestionSelectorViewController {

    var onSelect: ((Question, Option) -> Void)?

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? SelectAnswerCell,
            let question = self.viewModel.getQuestion(at: indexPath) {
            cell.onSelectOption = { [weak self] option in
                self?.onSelect?(question, option)
                self?.dismiss(animated: true, completion: nil)
            }
            cell.isCheckMarkHidden = true
        }

        return cell
    }

}
