//
//  SortOptionsViewController.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 06.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class SortOptionsViewController: UITableViewController {

    private (set) var titles: [String] = []

    var onMove: ((IndexPath, IndexPath) -> Void)?

    init(titles: [String]) {
        self.titles = titles

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.isEditing = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))
    }
    
    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveOption(from: sourceIndexPath, to: destinationIndexPath)
        self.onMove?(sourceIndexPath, destinationIndexPath)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.titles[indexPath.row]
        return cell
    }

    private func moveOption(from startIndexPath: IndexPath, to endIndexPath: IndexPath) {
        guard let option = self.titles[safe: startIndexPath.row],
            let startIndex = self.titles.firstIndex(of: option) else { return }

        self.titles.remove(at: startIndex)
        self.titles.insert(option, at: endIndexPath.row)

        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
