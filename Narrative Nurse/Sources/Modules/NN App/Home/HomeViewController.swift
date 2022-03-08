//
//  HomeViewController.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 26.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import AVFoundation
import NNCore

final class HomeViewController: BaseViewController {

    let viewModel: HomeViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)

    var onQuestions: ((QuestionsSequence, Facility) -> Void)?
    var onMenu: VoidClosure?
    
    init(viewModel: HomeViewModel) {
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
        self.navigationController?.viewControllers.removeFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
        
        self.tableView.reloadData()
    }

    private func setupViews() {
        let navigationView = NNNavigationView()
        navigationView.title = "Select your facility type"
        navigationView.isBackButtonHidden = true
        navigationView.onMenu = { [weak self] in
            self?.onMenu?()
        }
        
        let stackView = UIStackView(arrangedSubviews: [navigationView, self.tableView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.insetsLayoutMarginsFromSafeArea = false
        
        self.tableView.backgroundColor = .nn_lightGray
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.tableView.register(HomeCell.self, forCellReuseIdentifier: HomeCell.className)
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func openList() {
        self.onMenu?()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.facilities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCell.className) as? HomeCell,
              let facility = self.viewModel.facilities[safe: indexPath.row]
            else { return UITableViewCell() }
        
        cell.update(title: facility.title)
        cell.onSelected = { [weak self] in
            guard let questionsSequence = self?.viewModel.getSequence(for: facility) else { return }
            Analytics.shared.logEvent(Event.sequenceSelect(facility: facility, job: Preference.jobTitle))
            self?.onQuestions?(questionsSequence, facility)
        }

        return cell
    }
    
}

// MARK: UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
