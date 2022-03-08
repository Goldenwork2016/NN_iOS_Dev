//
//  BaseQuestionSelectorViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 03.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

class BaseQuestionSelectorViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    let viewModel: BaseQuestionSelectorViewModel
    
    init(viewModel: BaseQuestionSelectorViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))
        
        self.view.backgroundColor = .white
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.frame = .zero
        self.tableView.register(SelectAnswerCell.self, forCellReuseIdentifier: SelectAnswerCell.className)
        
        self.tableView.dataSource = self
        
        self.view.nn_addSubview(self.tableView)
    }

    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BaseQuestionSelectorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfQuestions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectAnswerCell.className) as? SelectAnswerCell, let question = self.viewModel.getQuestion(at: indexPath) else {
            return UITableViewCell()
        }
        
        cell.offsetLevel = self.viewModel.getOffsetLevel(at: indexPath)
        cell.isExpanded = self.viewModel.isExpanded(at: indexPath)
        cell.question = question
        cell.onExpand = { [weak self] in
            self?.viewModel.expandCollapse(at: indexPath)
        }
        
        return cell
    }
    
}
