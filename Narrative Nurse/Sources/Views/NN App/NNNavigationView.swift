//
//  NNNavigationView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 09.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class NNNavigationView: UIView {
    
    private let stackView = UIStackView()
    private let backButton = UIButton()
    private let menuButton = UIButton()
    private let titleLabel = UILabel()
    let menuView = NNDropdownMenuView()
    
    var isBackButtonHidden: Bool {
        set {
            self.backButton.isUserInteractionEnabled = !newValue
            self.backButton.alpha = newValue ? 0 : 1.0
        }
        get {
            return !self.backButton.isUserInteractionEnabled
        }
    }
    
    var isMenuButtonHidden: Bool {
        set {
            self.menuButton.isUserInteractionEnabled = !newValue
            self.menuButton.alpha = newValue ? 0 : 1.0
        }
        get {
            return !self.menuButton.isUserInteractionEnabled
        }
    }
    
    var title: String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }
    
    var menuItemsContainerView: MenuItemContainerView? {
        set {
            self.stackView.arrangedSubviews
                .compactMap { $0 as? MenuItemContainerView }
                .forEach { $0.removeFromSuperview() }
            self.menuView.isHidden = newValue == nil
            self.menuView.itemsContainerView = newValue
            if let newValue = newValue {
                self.stackView.insertArrangedSubview(newValue, at: self.stackView.arrangedSubviews.count - 1)
            }
        }
        get {
            return self.menuView.itemsContainerView
        }
    }
    
    var onBack: VoidClosure?
    var onMenu: VoidClosure?
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let middleContainerView = UIView()
        middleContainerView.addSubview(self.menuView)
        self.menuView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let logoImageView = UIImageView(image: Assets.logoOneRow.image)
        logoImageView.contentMode = .center
        
        self.backButton.setTitle("Back", for: .normal)
        self.backButton.setTitleColor(.nn_lightBlue, for: .normal)
        self.backButton.titleLabel?.font = .nn_font(type: .regular, sizeFont: 21)
        self.backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        self.backButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        self.menuButton.setImage(Assets.menu.image, for: .normal)
        self.menuButton.addTarget(self, action: #selector(self.menuButtonPressed), for: .touchUpInside)
        self.menuButton.imageView?.contentMode = .center
        self.menuButton.contentVerticalAlignment = .fill
        self.menuButton.contentHorizontalAlignment = .fill
        self.menuButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        let buttonStackView = UIStackView(arrangedSubviews: [self.backButton, middleContainerView, self.menuButton])
        buttonStackView.distribution = .fill
        buttonStackView.axis = .horizontal
        buttonStackView.layoutMargins = UIEdgeInsets(top: 21, left: 14, bottom: 10, right: 14)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(74)
        }
        
        self.titleLabel.font = .nn_font(type: .boldOblique, sizeFont: 30)
        self.titleLabel.textColor = .white
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textAlignment = .center
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.5
        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(71)
        }
        let titleLabelBackground = titleLabel.nn_wrappedWithGradientView(contentMargins: .init(top: 0, left: 15, bottom: 0, right: 15))
        
        self.stackView.distribution = .fill
        self.stackView.axis = .vertical
        self.stackView.spacing = 0
        self.stackView.insetsLayoutMarginsFromSafeArea = false
        self.stackView.layoutMargins = UIEdgeInsets(top: 62, left: 0, bottom: 0, right: 0)
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.addArrangedSubview(logoImageView)
        self.stackView.addArrangedSubview(buttonStackView)
        self.stackView.addArrangedSubview(titleLabelBackground)
        
        self.backgroundColor = .white
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.menuItemsContainerView = nil
    }
}

// MARK: - Actions
extension NNNavigationView {

    @objc private func backButtonPressed() {
        self.onBack?()
    }
    
    @objc private func menuButtonPressed() {
        self.onMenu?()
    }
}
