//
//  KeypadView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class NNKeypadView: UIView {
    
    private static let dotSymbol = "•"
    
    private lazy var dotButton: SizeViewButton = {
        let dotButton = self.button()
        dotButton.tag = 999
        dotButton.setTitle(NNKeypadView.dotSymbol, for: .normal)
        
        return dotButton
    }()
    
    var onDot: VoidClosure?
    var onClear: VoidClosure?
    var onNumber: IntClosure?
    
    var isDotHidden: Bool {
        set {
            let text = newValue ? String() : NNKeypadView.dotSymbol
            self.dotButton.setTitle(text, for: .normal)
            self.dotButton.isEnabled = !newValue
        }
        get {
            return self.self.dotButton.title(for: .normal)?.isEmpty ?? true
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let phonePadView = createPhonePadView()
        self.addSubview(phonePadView)
        phonePadView.snp.makeConstraints { make in
            make.width.equalTo(236)
            make.top.centerX.bottom.equalToSuperview()
        }
    }
    
    private func createPhonePadView() -> UIView {
        let phonePadStackView = UIStackView()
        phonePadStackView.axis = .vertical
        phonePadStackView.spacing = 8

        for verticalIndex in 0...2 {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .equalSpacing

            for horizontalIndex in 1...3 {
                let index = verticalIndex * 3 + horizontalIndex
                let button = self.button()
                button.tag = index
                button.setTitle("\(index)", for: .normal)

                horizontalStackView.addArrangedSubview(button)
            }

            phonePadStackView.addArrangedSubview(horizontalStackView)
        }

        let zeroButton = self.button()
        zeroButton.tag = 0
        zeroButton.setTitle("0", for: .normal)
        let clearButton = self.button()
        clearButton.tag = 100
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = .nn_font(type: .regular, sizeFont: 18)

        let bottomStackView = UIStackView(arrangedSubviews: [self.dotButton, zeroButton, clearButton])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .equalSpacing

        phonePadStackView.addArrangedSubview(bottomStackView)

        return phonePadStackView
    }
    
    private func button() -> SizeViewButton {
        let button = SizeViewButton()
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
        return button
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        if sender.tag == 999 {
            self.onDot?()
        } else if sender.tag == 100 {
            self.onClear?()
        } else if sender.tag < 10 {
            self.onNumber?(sender.tag)
        } else {
            assertionFailure("Unexpected click")
        }
    }
}

private class SizeViewButton: UIButton {

    private var shadowView = UIView()
    private var backgroundView = UIView()

    var hideSelectionAnimation: UIViewPropertyAnimator?

    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundView.backgroundColor = .white
        self.backgroundView.layer.borderWidth = 1.0
        self.backgroundView.layer.borderColor = UIColor.nn_midGray.cgColor
        self.backgroundView.nn_roundAllCorners(radius: .value(16))
        self.backgroundView.alpha = 0.0
        self.nn_addSubview(self.backgroundView)
        self.sendSubviewToBack(backgroundView)

        self.shadowView = UIView()
        self.shadowView.backgroundColor = .clear
        self.shadowView.alpha = 0.0
        self.nn_addSubview(self.shadowView)
        self.sendSubviewToBack(shadowView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.shadowView.layer.nn_applyShadow()
        }

        self.setTitleColor(UIColor.nn_lightBlue, for: .normal)
        self.titleLabel?.font = .nn_font(type: .regular, sizeFont: 30)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        setHighlighted(true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        setHighlighted(false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        setHighlighted(false)
    }

    private func setHighlighted(_ highlighed: Bool) {
        self.isHighlighted = highlighed
        if highlighed {
            if let fadeAnimation = self.hideSelectionAnimation {
                fadeAnimation.stopAnimation(true)
                self.hideSelectionAnimation = nil
            }
            self.shadowView.alpha = 1.0
            self.backgroundView.alpha = 1.0
            self.shadowView.layer.shadowOpacity = 1.0
        } else {
            self.hideSelectionAnimation = UIViewPropertyAnimator(duration: 0.6, curve: .easeIn) { [weak self] in
                self?.shadowView.layer.shadowOpacity = 0.0
                self?.shadowView.alpha = 0.0
                self?.backgroundView.alpha = 0.0
            }
            self.hideSelectionAnimation?.addCompletion { [weak self] _ in
                self?.hideSelectionAnimation = nil
            }

            self.hideSelectionAnimation?.startAnimation()
        }
    }

}
