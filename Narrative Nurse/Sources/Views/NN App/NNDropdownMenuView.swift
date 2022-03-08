//
//  NavigationBarMenuView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 19.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class NNDropdownMenuView: UIView {

    enum State {
        case closed
        case opened
    }

    private(set) var state: State = .closed

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    var itemsContainerView: MenuItemContainerView? {
        didSet {
            updateView()
        }
    }

    init() {
        super.init(frame: .zero)

        setupView()
        updateView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func switchState() {
        switch self.state {
        case .closed:
            self.state = .opened
        case .opened:
            self.state = .closed
        }

        updateView()
    }

    private func setupView() {
        self.titleLabel.font = .nn_font(type: .regular, sizeFont: 21)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .nn_lightBlue

        self.arrowImageView.contentMode = .center
        self.arrowImageView.heightAnchor.constraint(equalToConstant: 9).isActive = true
        self.arrowImageView.image = #imageLiteral(resourceName: "moreMenuIcon")

        let spacingView = UIView()
        spacingView.heightAnchor.constraint(equalToConstant: 5).isActive = true

        let stackView = UIStackView(arrangedSubviews: [spacingView, self.titleLabel, self.arrowImageView])
        stackView.spacing = -3
        stackView.axis = .vertical

        self.nn_addSubview(stackView)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.switchState)))
    }

    private func updateView() {
        let arrowTransform: CGAffineTransform
        switch self.state {
        case .closed:
            self.titleLabel.text = "More"
            arrowTransform = CGAffineTransform(rotationAngle: .pi * 2)
            self.itemsContainerView?.isHidden = true
        case .opened:
            self.titleLabel.text = "Less"
            arrowTransform = CGAffineTransform(rotationAngle: .pi)
            self.itemsContainerView?.isHidden = false
        }

        UIView.animate(withDuration: 0.15) {
            self.arrowImageView.transform = arrowTransform
        }
    }
}

final class MenuItemContainerView: UIView {

    private let stackView = UIStackView()

    private var closures: [VoidClosure] = []

    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.stackView.spacing = 10
        self.stackView.axis = .vertical
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = UIEdgeInsets(top: 28, left: 20, bottom: 28, right: 20)

        self.nn_addSubview(self.stackView)
    }

    func addItem(with text: String, closure: @escaping VoidClosure) {
        let button = UIButton()
        button.titleLabel?.font = .nn_font(type: .regular, sizeFont: 21)
        button.setTitleColor(.nn_lightBlue, for: .normal)
        button.setTitleColor(UIColor.nn_lightBlue.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.nn_lightBlue.withAlphaComponent(0.7), for: .selected)
        button.setTitle(text, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.tag = stackView.arrangedSubviews.count
        button.addTarget(self, action: #selector(self.onClick(_:)), for: .touchUpInside)
        self.stackView.addArrangedSubview(button)
        self.closures.append(closure)
    }
    
    func updateTitle(_ title: String, index: Int) {
        guard let button = self.stackView.arrangedSubviews[safe: index] as? UIButton else {
            assertionFailure("Can't find button at index \(index)")
            return
        }
        
        button.setTitle(title, for: .normal)
    }
    
    @objc private func onClick(_ button: UIButton) {
        guard let closure = self.closures[safe: button.tag] else {
            return
        }

        closure()
    }

}
