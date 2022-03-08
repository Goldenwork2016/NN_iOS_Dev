//
//  ImageSelectorView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsImageSelectorView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let fileLabel = UILabel()
    private let multiselectionCheckmark = CheckmarkButton()
    private let multiselectionLabel = UILabel()
    private let chooseFileButton = BuilderButton()

    var onUpdated: VoidClosure?

    var kind: Question.Kind? {
        return .image(imagePath: self.filename ?? "", multiselection: self.multiselection)
    }

    var filename: String? {
        didSet {
            self.fileLabel.text = self.filename
        }
    }

    var multiselection: Bool = false {
        didSet {
            self.multiselectionCheckmark.isSelected = self.multiselection
        }
    }

    var onPresentPicker: (([String], @escaping(StringClosure)) -> Void)?

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
        self.chooseFileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.chooseFileButton.widthAnchor.constraint(equalToConstant: 85).isActive = true

        let chooseFileButtonStackView = UIStackView(arrangedSubviews: [self.fileLabel, self.chooseFileButton])
        chooseFileButtonStackView.axis = .horizontal

        self.multiselectionCheckmark.onTap = { [weak self] in
            self?.multiselectionToggled()
        }
        self.multiselectionCheckmark.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.multiselectionCheckmark.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.multiselectionLabel.text = "Multiselection"

        let multiselectionStackView = UIStackView(arrangedSubviews: [self.multiselectionCheckmark, self.multiselectionLabel])
        multiselectionStackView.axis = .horizontal
        multiselectionStackView.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [chooseFileButtonStackView, multiselectionStackView])
        stackView.axis = .vertical
        stackView.spacing = 10

        self.nn_addSubview(stackView)
    }

    @objc private func chooseFile() {
        let folder = Folder.images
        let fileManager = FileManager.default

        if let path = Bundle.main.path(forResource: folder.path, ofType: nil), let docsArray = try? fileManager.contentsOfDirectory(atPath: path) {

            self.onPresentPicker?(docsArray) { [weak self] filename in
                self?.filename = filename
                self?.onUpdated?()
            }
        }
    }

    private func multiselectionToggled() {
        self.multiselection.toggle()
        self.onUpdated?()
    }
}
