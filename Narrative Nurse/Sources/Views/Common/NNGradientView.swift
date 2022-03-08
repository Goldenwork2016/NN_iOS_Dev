//
//  GradientView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 26.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class NNGradientView<WrappedView: UIView>: UIView {

    private let stackView = UIStackView()

    let wrappedView: WrappedView

    var contentMargins: UIEdgeInsets {
        set {
            self.stackView.layoutMargins = newValue
        }
        get {
            return self.stackView.layoutMargins
        }
    }

    init(wrappedView: WrappedView) {
        self.wrappedView = wrappedView

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.stackView.axis = .horizontal
        self.stackView.spacing = 0
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.addArrangedSubview(self.wrappedView)

        self.nn_addSubview(self.stackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setBackgroundGradientColor([.nn_turquoise, .nn_lightBlue], direction: .horizontal)
    }
}

protocol GradientWrappable {}

extension UIView: GradientWrappable {}

extension GradientWrappable where Self: UIView {

    func nn_wrappedWithGradientView(contentMargins: UIEdgeInsets = .zero) -> NNGradientView<Self> {
        let gradientView = NNGradientView(wrappedView: self)
        gradientView.contentMargins = contentMargins
        return gradientView
    }

}
