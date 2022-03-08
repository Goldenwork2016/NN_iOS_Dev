//
//  UITableView+Header.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UITableView {

    func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        self.tableHeaderView = headerView

        // ** Must setup AutoLayout after set tableHeaderView.
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }

    func updateHeaderViewFrameIfNeeded() {
        guard let headerView = self.tableHeaderView else { return }

        let oldSize = headerView.bounds.size
        // Update the size
        headerView.layoutIfNeeded()
        let newSize = headerView.bounds.size

        if oldSize != newSize {
            self.beginUpdates()
            self.endUpdates()
        }
    }
}
