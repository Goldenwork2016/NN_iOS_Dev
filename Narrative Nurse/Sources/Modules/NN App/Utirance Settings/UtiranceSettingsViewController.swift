//
//  UtiranceSettingsViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 26.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore
import AVFoundation

final class UtiranceSettingsViewController: NNModalViewController {

    let viewModel: UtiranceSettingsViewModel

    init(viewModel: UtiranceSettingsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.spacing = 0
        stackView.axis = .vertical
        self.containerView.nn_addSubview(stackView)

        let titleLabel = UILabel()
        titleLabel.font = .nn_font(type: .bold, sizeFont: 40)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "Speech Settings"
        let titleContainerView = UIView()
        titleContainerView.nn_addSubview(titleLabel) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30)
            ]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            titleContainerView.setBackgroundGradientColor([.nn_turquoise, .nn_lightBlue], direction: .horizontal)
        }
        stackView.addArrangedSubview(titleContainerView)
        stackView.setCustomSpacing(1, after: titleContainerView)

        for setting in UtiranceSetting.allCases {
            let rateView = getSettingView(for: setting)
            stackView.addArrangedSubview(rateView)
        }

        stackView.addArrangedSubview(UIView())

        let okayButton = NNButton()
        okayButton.setTitle("Close", for: .normal)
        okayButton.backgroundColor = .white
        okayButton.addTarget(self, action: #selector(self.onCloseClicked), for: .touchUpInside)

        let okayButtonStackView = UIStackView(arrangedSubviews: [okayButton])
        okayButtonStackView.layoutMargins = .init(top: 8, left: 30, bottom: 24, right: 30)
        okayButtonStackView.isLayoutMarginsRelativeArrangement = true
        okayButtonStackView.insetsLayoutMarginsFromSafeArea = false
        okayButtonStackView.backgroundColor = .white

        stackView.addArrangedSubview(okayButtonStackView)
    }

    private func getSettingView(for setting: UtiranceSetting) -> UIView {
        let valueLabel = UILabel()
        valueLabel.font = .nn_font(type: .bold, sizeFont: 24)
        valueLabel.textColor = .nn_orange
        valueLabel.text = self.viewModel.getCurrentValueString(for: setting)
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.font = .nn_font(type: .boldOblique, sizeFont: 28)
        titleLabel.text = setting.title
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        let titleLabelGradientView = titleLabel.nn_wrappedWithGradientView()

        let slider = NNSlider()
        slider.minimumValue = setting.minValue
        slider.maximumValue = setting.maxValue
        slider.value = self.viewModel.getCurrentValue(for: setting)
        slider.onValueChanged = { [weak self] in
            self?.viewModel.setCurrentValue(slider.value, for: setting)
            valueLabel.text = self?.viewModel.getCurrentValueString(for: setting)
        }
        slider.onValueChangeEnded = { [weak self] in
            slider.value = self?.viewModel.getCurrentValue(for: setting) ?? 0
        }

        let slicerStackView = UIStackView(arrangedSubviews: [slider])
        slicerStackView.axis = .horizontal
        slicerStackView.distribution = .fillEqually
        slicerStackView.isLayoutMarginsRelativeArrangement = true
        slicerStackView.layoutMargins = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 75)

        let stackView = UIStackView(arrangedSubviews: [titleLabelGradientView, valueLabel, slicerStackView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0)
        stackView.setCustomSpacing(12, after: titleLabelGradientView)
        stackView.setCustomSpacing(3, after: valueLabel)

        return stackView
    }

    @objc private func onCloseClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}
