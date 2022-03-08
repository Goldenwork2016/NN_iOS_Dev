//
//  GlobalSettingsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class GlobalSettingsViewController: UIViewController {

    let viewModel: GlobalSettingsViewModel

    var onSelect: ((GlobalSettingKind) -> Void)?

    private let tableView = UITableView()

    init(viewModel: GlobalSettingsViewModel) {
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)

        self.view.nn_addSubview(self.tableView)
    }
}

// MARK: - UITableViewDataSource
extension GlobalSettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        let item = self.viewModel.options[indexPath.row]
        cell.textLabel?.text = self.viewModel.getTitle(for: item)

        return cell
    }

}

// MARK: - UITableViewDelegate
extension GlobalSettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.viewModel.options[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true) { [weak self] in
            self?.onSelect?(option)
        }
    }

}
