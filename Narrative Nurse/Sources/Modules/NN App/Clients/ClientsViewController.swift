//
//  ClientsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class ClientsViewController: UIViewController {
    let viewModel: ClientsViewModel
    
    private let tableView = UITableView()
    
    var onStart: Closure<ClientIdentifier>?
    var onContinue: ((ClientIdentifier, UnfinishedSequence) -> Void)?
    var onPreview: StringClosure?
    
    init(viewModel: ClientsViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.reloadData()
        self.tableView.reloadData()
    }
    
    private func setupView() {
        let navigationView = NNNavigationView()
        navigationView.title = "Clients"
        navigationView.isMenuButtonHidden = true
        navigationView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let menuItemContainerView = MenuItemContainerView()
        menuItemContainerView.addItem(with: "Delete all clients", closure: { [weak self, weak navigationView] in

            let alert = UIAlertController(title: "Delete", message: "Do you want to delete all saved rooms?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                self?.viewModel.deleteAllClients()
                self?.tableView.reloadData()
                self?.navigationController?.popViewController(animated: true)
            }))
            self?.present(alert, animated: true, completion: nil)
            
            navigationView?.menuView.switchState()
        })
        
        menuItemContainerView.addItem(with: "Rearrange clients", closure: { [weak self, weak navigationView, weak menuItemContainerView] in
            guard let sself = self else { return }
            
            navigationView?.menuView.switchState()
            sself.tableView.isEditing.toggle()
            let editingTitle = sself.tableView.isEditing ? "Finish rearranging" : "Rearrange clients"
            menuItemContainerView?.updateTitle(editingTitle, index: 1)
        })

        navigationView.menuItemsContainerView = menuItemContainerView
        
        self.tableView.backgroundColor = .nn_lightGray
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.register(ClientCell.self, forCellReuseIdentifier: ClientCell.className)
        
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

}


// MARK: - UITableViewDataSource
extension ClientsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.clientIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClientCell.className, for: indexPath) as? ClientCell,
            let clientIdentifier = self.viewModel.clientIdentifiers[safe: indexPath.row] else {
            return UITableViewCell()
        }
       
        if let unfinishedSequence = self.viewModel.getUnfinishedSequence(for: clientIdentifier) {
            cell.update(clientIdentifier: clientIdentifier, preview: .unfinishedSequence)
            cell.onPreview = { [weak self] in
                guard let sself = self else { return }
                let textPreview = sself.viewModel.getNarrative(for: unfinishedSequence)
                sself.onPreview?(textPreview)
            }
            cell.onStart = { [weak self] in
                self?.onContinue?(clientIdentifier, unfinishedSequence)
            }
        }
        else if let lastNoteHistory = self.viewModel.getLastNoteHistory(for: clientIdentifier) {
            cell.update(clientIdentifier: clientIdentifier, preview: .noteHistory)
            cell.onPreview = { [weak self] in
                self?.onPreview?(lastNoteHistory.value)
            }
            cell.onStart = { [weak self] in
                self?.onStart?(clientIdentifier)
            }
        }
        else {
            cell.update(clientIdentifier: clientIdentifier, preview: .none)
            cell.onStart = { [weak self] in
                self?.onStart?(clientIdentifier)
            }
        }
        
        cell.onDelete = { [weak self] in
            self?.viewModel.delete(client: clientIdentifier)
            self?.tableView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.viewModel.moveClient(from: sourceIndexPath.row, to: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITableViewDelegate
extension ClientsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }
}

