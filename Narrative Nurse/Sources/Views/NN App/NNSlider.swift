//
//  NNSlider.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 27.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class NNSlider: UISlider {

    init() {
        super.init(frame: .zero)

        setup()
    }

    var onValueChanged: VoidClosure?
    var onValueChangeEnded: VoidClosure?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.maximumTrackTintColor = .nn_midGray
        self.addTarget(self, action: #selector(onChangeValue(_:)), for: .valueChanged)
        self.addTarget(self, action: #selector(onChangeValueEnd(_:)), for: .touchUpInside)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.setupGradientProgress()
        }
    }

    private func setupGradientProgress() {
        let tgl = CAGradientLayer()
        let frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 2.0)
        tgl.frame = frame
        tgl.colors = [UIColor.nn_turquoise.cgColor, UIColor.nn_lightBlue.cgColor]
        tgl.endPoint = CGPoint(x: 1.0, y: 1.0)
        tgl.startPoint = CGPoint(x: 0.0, y: 1.0)

        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            tgl.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setMinimumTrackImage(image?.resizableImage(withCapInsets: .zero), for: .normal)
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 2
        return result
    }
}

// MARK: - Actions
extension NNSlider {

    @objc private func onChangeValue(_ slider: UISlider) {
        self.onValueChanged?()
    }

    @objc private func onChangeValueEnd(_ slider: UISlider) {
        self.onValueChangeEnded?()
    }

}
