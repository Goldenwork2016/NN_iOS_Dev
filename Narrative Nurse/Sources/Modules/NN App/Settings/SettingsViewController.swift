//
//  SettingsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsViewController: BaseViewController {

    let viewModel: SettingsViewModel

    private let buttonsStackView = UIStackView()

    init(viewModel: SettingsViewModel) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateButtonState()
    }

    private func updateButtonState() {
        for view in buttonsStackView.arrangedSubviews {
            if let job = self.viewModel.jobs[safe: view.tag],
                let button = view as? NNSelectableButton {
                button.isSelected = self.viewModel.isSelected(job: job)
            }
        }
    }

}

// MARK: - Actions
extension SettingsViewController {

    @objc private func onJobSelected(button: UIButton) {
        guard let job = self.viewModel.jobs[safe: button.tag] else { return }

        self.viewModel.select(job: job)

        updateButtonState()
    }

}

// MARK: - Setup views
extension SettingsViewController {

    private func setupViews() {
        let navigationView = NNNavigationView()
        navigationView.title = "Choose your title"
        navigationView.isMenuButtonHidden = true
        navigationView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

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
