//
//  FeedbackViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 08.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import Foundation
import NNCore
import SnapKit

final class FeedbackViewController: NNModalViewController {

    let viewModel: FeedbackViewModel

    init(viewModel: FeedbackViewModel) {
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

    private func setupViews() {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.spacing = 0
        stackView.axis = .vertical
        self.containerView.nn_addSubview(stackView)

        let titleLabel = UILabel()
        titleLabel.font = .nn_font(type: .bold, sizeFont: 40)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "Feedback"
        let titleGradientView = titleLabel.nn_wrappedWithGradientView(contentMargins: .init(top: 22, left: 30, bottom: 30, right: 30))
        stackView.addArrangedSubview(titleGradientView)

        let descriptionTextView = UITextView()
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 44, left: 27, bottom: 30, right: 27)
        descriptionTextView.font = .nn_font(type: .regular, sizeFont: 21)
        descriptionTextView.textColor = .black
        descriptionTextView.isEditable = false
        descriptionTextView.backgroundColor = .nn_lightGray
        descriptionTextView.textAlignment = .left
        descriptionTextView.text = self.viewModel.guideString
        stackView.addArrangedSubview(descriptionTextView)

        let closeButton = NNButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .white
        closeButton.addTarget(self, action: #selector(self.onCloseClicked), for: .touchUpInside)

        let startButton = NNButton()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .white
        startButton.addTarget(self, action: #selector(self.onSendClicked), for: .touchUpInside)

        let okayButtonStackView = UIStackView(arrangedSubviews: [closeButton, startButton])
        okayButtonStackView.layoutMargins = .init(top: 8, left: 0, bottom: 24, right: 0)
        okayButtonStackView.isLayoutMarginsRelativeArrangement = true
        okayButtonStackView.insetsLayoutMarginsFromSafeArea = false
        okayButtonStackView.backgroundColor = .white
        okayButtonStackView.distribution = .fillEqually

        stackView.addArrangedSubview(okayButtonStackView)
    }

    @objc private func onCloseClicked() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func onSendClicked() {
        self.viewModel.feedbackSender.delegate = self
        self.viewModel.feedbackSender.sendFeedback(from: self)
    }
}

// MARK: - FeedbackSenderDelegate
extension FeedbackViewController: FeedbackSenderDelegate {
    func didReceiveStatus(feedbackSender: FeedbackSender, status: FeedbackSender.Status) {
        switch status {
        case .sent, .cancelled:
            self.dismiss(animated: false, completion: nil)
        case .failed(let error):
            let alert = UIAlertController(title: error.displayTitle, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
