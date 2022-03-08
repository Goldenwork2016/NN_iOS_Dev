//
//  ListViewController.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 02.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class NoteHistoryViewController: BaseViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)

    let viewModel: NoteHistoryViewModel

    var onResult: ((NoteHistory) -> Void)?

    init(viewModel: NoteHistoryViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
        self.tableView.reloadData()
    }

    private func setupViews() {
        let navigationView = NNNavigationView()
        navigationView.title = "Note History"
        navigationView.isMenuButtonHidden = true
        navigationView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.tableView.backgroundColor = .nn_lightGray
        self.tableView.separatorStyle = .none
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 20))
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 20))
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.bounces = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(NoteHistoryTableViewCell.self, forCellReuseIdentifier: NoteHistoryTableViewCell.className)
        
        let stackView = UIStackView(arrangedSubviews: [navigationView, self.tableView])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.spacing = 0
        stackView.axis = .vertical
        
        self.view.backgroundColor = .white
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NoteHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteHistoryTableViewCell.className) as? NoteHistoryTableViewCell,
            let noteHistory = self.viewModel.getNoteHistory(for: indexPath)
            else { return UITableViewCell() }

        cell.update(clientIdentifier: noteHistory.clientIdentifier, date: noteHistory.createdAt)

        return cell
    }
}

// MARK: UITableViewDelegate
extension NoteHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sentence = self.viewModel.getNoteHistory(for: indexPath) else { return }
        self.onResult?(sentence)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let text = self.viewModel.getKey(for: section) else { return UIView() }
        let headerView = NoteHistoryHeaderView()
        headerView.text = text

        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
