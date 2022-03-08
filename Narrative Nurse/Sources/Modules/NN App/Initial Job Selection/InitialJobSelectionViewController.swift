//
//  InitialJobSelectionViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class InitialJobSelectionViewController: BaseViewController {

    let viewModel: InitialJobSelectionViewModel
    
    private let buttonsStackView = UIStackView()
    
    var onSelected: VoidClosure?
    
    init(viewModel: InitialJobSelectionViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        self.navigationController?.viewControllers.removeFirst()
    }

}

// MARK: - Actions
extension InitialJobSelectionViewController {

    @objc private func onJobSelected(button: UIButton) {
        guard let job = self.viewModel.jobs[safe: button.tag] else { return }
        
        self.viewModel.select(job: job)
        
        for view in self.buttonsStackView.arrangedSubviews {
            if let viewJob = self.viewModel.jobs[safe: view.tag],
                let button = view as? NNSelectableButton {
                button.isSelected = viewJob == job
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] timer in
            self?.onSelected?()
        }
    }

}

// MARK: - Setup views
extension InitialJobSelectionViewController {

    private func setupViews() {
        let navigationView = NNNavigationView()
        navigationView.title = "Choose your title"
        navigationView.isMenuButtonHidden = true
        navigationView.isBackButtonHidden = true
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .nn_lightGray

        self.buttonsStackView.axis = .vertical
        self.buttonsStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 6, right: 16)
        self.buttonsStackView.isLayoutMarginsRelativeArrangement = true
        for index in self.viewModel.jobs.indices {
            let job = self.viewModel.jobs[index]
            let button = NNSelectableButton()
            button.title = job.title
            button.tag = index
            button.button.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)
            button.addTarget(self, action: #selector(onJobSelected(button:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
            button.isSelected = false
            self.buttonsStackView.addArrangedSubview(button)
        }
        scrollView.addSubview(self.buttonsStackView)
        self.buttonsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let stackView = UIStackView(arrangedSubviews: [navigationView, scrollView])
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.insetsLayoutMarginsFromSafeArea = false

        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
