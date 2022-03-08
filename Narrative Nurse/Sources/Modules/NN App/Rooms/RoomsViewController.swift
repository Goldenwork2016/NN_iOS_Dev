//
//  RoomsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class RoomsViewController: UIViewController {
    
    let viewModel: RoomsViewModel
    
    private let tableView = UITableView()
    private let nextButton = NNButton()
    
    var onAdd: Closure<BoolClosure>?
    var onNext: VoidClosure?
    
    init(viewModel: RoomsViewModel) {
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
        
        updateView()
    }
    
    private func updateView() {
        self.viewModel.updateRooms()
        self.tableView.reloadData()
        self.nextButton.isHidden = self.viewModel.rooms.isEmpty
    }
    
    private func setupView() {
        let navigationView = NNNavigationView()
        navigationView.title = "Selected rooms"
        navigationView.isMenuButtonHidden = true
        navigationView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.tableView.backgroundColor = .nn_lightGray
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.register(RoomsCell.self, forCellReuseIdentifier: RoomsCell.className)
        
        let addButton = NNButton()
        addButton.setTitle("Add", for: .normal)
        addButton.backgroundColor = .white
        addButton.addTarget(self, action: #selector(self.onAddClicked), for: .touchUpInside)

        self.nextButton.setTitle("Next", for: .normal)
        self.nextButton.backgroundColor = .white
        self.nextButton.addTarget(self, action: #selector(self.onNextClicked), for: .touchUpInside)
        
        let nextButtonContainer = UIView()
        nextButtonContainer.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let buttonsStackView = UIStackView(arrangedSubviews: [addButton, nextButtonContainer])
        buttonsStackView.layoutMargins = .init(top: 8, left: 0, bottom: 24, right: 0)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        buttonsStackView.insetsLayoutMarginsFromSafeArea = false
        buttonsStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [navigationView, tableView, buttonsStackView])
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


// MARK: - Actions
extension RoomsViewController {
    
    @objc private func onAddClicked() {
        self.onAdd? { [weak self] _ in
            self?.updateView()
        }
    }
    
    @objc private func onNextClicked() {
        self.onNext?()
    }
    
}


// MARK: - UITableViewDataSource
extension RoomsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomsCell.className, for: indexPath) as? RoomsCell,
        let roomNumber = self.viewModel.getRoomNumber(at: indexPath.row),
        let roomSections = self.viewModel.rooms[roomNumber] else {
            return UITableViewCell()
        }
        
        cell.update(with: roomNumber, and: roomSections)
        cell.onDelete = { [weak self] in
            self?.viewModel.deleteRoom(at: indexPath.row)
            self?.updateView()
        }
        
        return cell
    }

}

// MARK: - UITableViewDelegate
extension RoomsViewController: UITableViewDelegate {

}

