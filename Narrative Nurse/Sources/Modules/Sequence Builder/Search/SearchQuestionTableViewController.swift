//
//  SearchQuestionViewController.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SearchQuestionTableViewController: UITableViewController {
    private let searchController = UISearchController()

    let viewModel: SearchQuestionTableViewModel
    var onSelect: ((SearchQuestionTableViewModel.SearchItem) -> Void)?

    init(viewModel: SearchQuestionTableViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.items[ indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)

        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.type

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.viewModel.items[indexPath.row]
        self.onSelect?(item)
        self.searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchQuestionTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        self.viewModel.filter(with: text)
        self.tableView.reloadData()
    }

}
