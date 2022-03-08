//
//  FindAndReplaceViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 25.09.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class EditGlobalSettingsViewController: UIViewController {
    
    let viewModel: EditGlobalSettingsViewModel

    private let tableView = UITableView()
    
    init(viewModel: EditGlobalSettingsViewModel) {
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
        self.title = self.viewModel.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onAdd))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.register(EditGlobalSettingItemCell.self, forCellReuseIdentifier: EditGlobalSettingItemCell.className)
        self.view.nn_addSubview(self.tableView) { (view, container) -> [NSLayoutConstraint] in
            let bottomConstraint = KeyboardLayoutConstraint(fromItem: view, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0)
            return [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bottomConstraint,
                view.topAnchor.constraint(equalTo: container.topAnchor)
            ]
        }

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapView)))
        self.view.backgroundColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewModel.save()
    }
}

// MARK: - Actions
extension EditGlobalSettingsViewController {
    
    @objc private func onAdd() {
        self.viewModel.addNew()
        self.tableView.reloadData()
    }
    
    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onTapView() {
        self.view.endEditing(true)
    }
    
    private func deteteSettingItem(at indexPath: IndexPath) {
        let value = self.viewModel.getSettingItem(at: indexPath)
        let alert = UIAlertController(title: nil, message: "Do you want to delete [\"\(value.key)\"-\"\(value.value)\"]?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.delete(at: indexPath)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension EditGlobalSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.countElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EditGlobalSettingItemCell.className, for: indexPath) as? EditGlobalSettingItemCell else {
            return UITableViewCell()
        }
        
        let item = self.viewModel.getSettingItem(at: indexPath)
        cell.update(with: item.key, and: item.value)
        cell.onEdit = { [weak self] (key, value) in
            self?.viewModel.update(at: indexPath, key: key, value: value)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let keyLabel = UILabel()
        keyLabel.font = .preferredFont(forTextStyle: .headline)
        keyLabel.text = self.viewModel.keyTitle
        
        let valueLabel = UILabel()
        valueLabel.font = .preferredFont(forTextStyle: .headline)
        valueLabel.text = self.viewModel.valueTitle
        
        let stackView = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        headerView.nn_addSubview(stackView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.deteteSettingItem(at: indexPath)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }
}
