//
//  ReusableSelectorView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsReusableSelectorView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let currentFileLabel = UILabel()
    private let chooseFileButton = BuilderButton()
    var onUpdated: VoidClosure?

    var filename: String? {
        didSet {
            self.currentFileLabel.text = "\(self.filename ?? "").json"
        }
    }

    var onPresentFileSelector: ((SequenceFileType, @escaping URLClosure) -> Void)?

    var kind: Question.Kind? {
        return .reusable(filename: self.filename ?? "")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.chooseFileButton.setTitle("Choose", for: .normal)
        self.chooseFileButton.addTarget(self, action: #selector(self.chooseFile), for: .touchUpInside)
        self.chooseFileButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        self.chooseFileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.currentFileLabel.lineBreakMode = .byTruncatingHead

        let chooseFileButtonStackView = UIStackView(arrangedSubviews: [self.currentFileLabel, self.chooseFileButton])
        chooseFileButtonStackView.axis = .horizontal

        self.nn_addSubview(chooseFileButtonStackView)
    }

    @objc private func chooseFile() {
        self.onPresentFileSelector?(.shared, { [weak self] newValue in
            self?.filename = newValue.lastPathComponent.removingPercentEncoding?.replacingOccurrences(of: ".json", with: "") ?? ""
            self?.onUpdated?()
        })
    }

}
