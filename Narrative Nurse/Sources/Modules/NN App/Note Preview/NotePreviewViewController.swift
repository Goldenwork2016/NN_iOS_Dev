//
//  NotePreviewViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 23.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class NotePreviewViewController: NNModalViewController {

    let narrative: String

    init(narrative: String) {
        self.narrative = narrative

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
        let resultsPreviewView = QuestionsResultsPreview()
        resultsPreviewView.onClose = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        resultsPreviewView.updateNarrative(self.narrative)

        self.containerView.nn_addSubview(resultsPreviewView)
    }
}
