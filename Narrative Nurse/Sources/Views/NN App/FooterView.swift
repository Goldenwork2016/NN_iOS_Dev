//
//  FooterView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 18.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class FooterView: UIView {

    private let imageView = UIImageView(image: Assets.questionsFooter.image)
    private var leadingContainerView = UIView()
    private var centerContainerView = UIView()
    private var trailingContainerView = UIView()

    var showShadow: Bool {
        set {
            self.imageView.image = newValue ? Assets.questionsFooterWithShadow.image : Assets.questionsFooter.image
        }
        get {
            return self.imageView.image?.cgImage === Assets.questionsFooterWithShadow.image.cgImage
        }
    }

    init() {
        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.nn_addSubview(self.imageView)

        self.leadingContainerView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        self.trailingContainerView.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let stackView = UIStackView(arrangedSubviews: [self.leadingContainerView, self.centerContainerView, self.trailingContainerView])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 3, bottom: 8, right: 3)

        self.nn_addSubview(stackView)
    }

}

// MARK: - Properties
extension FooterView {

    var leadingView: UIView? {
        set {
            self.leadingContainerView.subviews.forEach { $0.removeFromSuperview() }

            if let view = newValue {
                self.leadingContainerView.nn_addSubview(view, layoutConstraints: UIView.nn_constraintsCenter)
            }
        }
        get {
            return self.leadingContainerView.subviews.first
        }
    }

    var centerView: UIView? {
        set {
            self.centerContainerView.subviews.forEach { $0.removeFromSuperview() }
            if let view = newValue {
                self.centerContainerView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(self.showShadow ? -4 : -10)
                }
            }
        }
        get {
            return self.centerContainerView.subviews.first
        }
    }

    var trailingView: UIView? {
        set {
            self.trailingContainerView.subviews.forEach { $0.removeFromSuperview() }
            if let view = newValue {
                self.trailingContainerView.nn_addSubview(view, layoutConstraints: UIView.nn_constraintsCenter)
            }
        }
        get {
            return self.trailingContainerView.subviews.first
        }
    }

}

// MARK: - Static
extension FooterView {

    static func attach(to view: UIView) -> FooterView {
        let footerView = FooterView()
        view.nn_addSubview(footerView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: 103)
            ]
        }

        return footerView
    }

}
