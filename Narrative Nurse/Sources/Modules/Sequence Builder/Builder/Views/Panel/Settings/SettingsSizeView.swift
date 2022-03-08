//
//  SimpleKindView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SettingsSizeView: SettingsBaseQuestionView, SettingsQuestionKind {

    private let label = UILabel()

    var title: String? {
        didSet {
            self.label.text = self.title
        }
    }

    var kind: Question.Kind? {
        return nil
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
        self.label.textColor = .black
        self.label.numberOfLines = 0

        self.nn_addSubview(self.label)
    }
}
