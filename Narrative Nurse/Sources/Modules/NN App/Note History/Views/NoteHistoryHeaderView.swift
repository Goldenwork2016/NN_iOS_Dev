//
//  SentenceHeaderView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 30.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class NoteHistoryHeaderView: UIView {

    private let label = UILabel()

    var text: String? {
        set {
            self.label.text = newValue
        }
        get {
            return self.label.text
        }
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
        self.backgroundColor = .clear

        self.label.font = .nn_font(type: .boldOblique, sizeFont: 28)
        self.label.textColor = .white
        self.label.textAlignment = .center
        
        let labelWithBacground = label.nn_wrappedWithGradientView(contentMargins: .init(top: 0, left: 16, bottom: 0, right: 16))
        labelWithBacground.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        self.addSubview(labelWithBacground)
        labelWithBacground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
    }
}
