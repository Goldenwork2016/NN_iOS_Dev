//
//  SizeView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 11.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SizeView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    var unit: String {
        return self.option.kind.unit ?? ""
    }

    var formattedValue: String {
        if self.value.isEmpty {
           return "0"
        } else if self.value.first == "." {
            return "0\(self.value)"
        } else {
            return self.value
        }
    }

    private var value: String = "" {
        didSet {
            self.valueLabel.text = "\(self.formattedValue) \(self.unit)"
            self.onValue?(Double(self.value))
        }
    }

    let option: Option

    var onValue: ((Double?) -> Void)?

    init(option: Option) {
        self.option = option

        super.init(frame: .zero)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.titleLabel.text = self.option.kind.title
        self.titleLabel.textColor = .white
        self.titleLabel.font = .nn_font(type: .boldOblique, sizeFont: 28)

        self.valueLabel.text = "0 \(self.unit)"
        self.valueLabel.textColor = .white
        self.valueLabel.font = .nn_font(type: .boldOblique, sizeFont: 28)

        let topStackView = UIStackView(arrangedSubviews: [self.titleLabel, UIView(), self.valueLabel])
        topStackView.axis = .horizontal
        topStackView.spacing = 10
        topStackView.isLayoutMarginsRelativeArrangement = true
        topStackView.layoutMargins = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 31)
        topStackView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let topStackViewBackgroundView = UIView()
        topStackView.nn_addSubview(topStackViewBackgroundView)
        topStackView.sendSubviewToBack(topStackViewBackgroundView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            topStackViewBackgroundView.setBackgroundGradientColor([.nn_turquoise, .nn_lightBlue], direction: .horizontal)
        }

        let phonepadView = NNKeypadView()
        phonepadView.onDot = { [weak self] in
            guard let sself = self else { return }
            if !sself.value.contains(".") {
                sself.value.append(".")
            }
        }
        phonepadView.onClear = { [weak self] in
            self?.value = ""
        }
        phonepadView.onNumber = { [weak self] number in
            self?.value.append("\(number)")
        }

        let stackView = UIStackView(arrangedSubviews: [topStackView, phonepadView])
        stackView.axis = .vertical
        stackView.spacing = 22

        self.nn_addSubview(stackView)
    }
}
