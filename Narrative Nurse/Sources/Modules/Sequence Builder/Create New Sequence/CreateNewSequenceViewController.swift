//
//  CreateNewSequenceViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 16.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

final class CreateNewSequenceViewController: UIViewController {

    let viewModel: CreateNewSequenceViewModel

    var onSelect: ((CreateNewSequenceViewModel.Kind) -> Void)?

    private let tableView = UITableView()

    init(viewModel: CreateNewSequenceViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        self.title = "New Sequence"

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)

        self.view.nn_addSubview(self.tableView)
    }
}

// MARK: - UITableViewDataSource
extension CreateNewSequenceViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        cell.textLabel?.text = self.viewModel.options[indexPath.row].rawValue

        return cell
    }

}

// MARK: - UITableViewDelegate
extension CreateNewSequenceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.viewModel.options[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true) { [weak self] in
            self?.onSelect?(option)
        }
    }

}
