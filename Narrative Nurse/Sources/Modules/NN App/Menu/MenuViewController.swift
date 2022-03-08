//
//  MenuViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class MenuViewController: BaseViewController {

    private static let menuBackgroundColor = UIColor(red: 24.0/255.0, green: 24.0/255.0, blue: 25.0/255.0, alpha: 1.0)

    let viewModel: MenuViewModel
    var onMenuItem: Closure<MenuItem>?

    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.view.backgroundColor = MenuViewController.menuBackgroundColor

        let logoImageView = UIImageView()
        logoImageView.image = Assets.logoTwoRowsLight.image
        logoImageView.contentMode = .center

        let closeButton = UIButton()
        closeButton.setImage(Assets.closeMenu.image, for: .normal)
        closeButton.addTarget(self, action: #selector(self.onClose), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        let closeButtonStackView = UIStackView(arrangedSubviews: [UIView(), closeButton])
        closeButtonStackView.axis = .horizontal
        closeButtonStackView.distribution = .fill

        let headerStackView = UIStackView(arrangedSubviews: [closeButtonStackView, logoImageView])
        headerStackView.axis = .vertical
        headerStackView.spacing = 42
        headerStackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)

        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 20
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)

        for index in self.viewModel.menu.indices {
            let menuItem = self.viewModel.menu[index]
            let buttonView = self.createButtonView(menuItem: menuItem)
                buttonView.tag = index

            let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.onOptionSelected(_:)))
            buttonView.addGestureRecognizer(tapGestureRecogniser)

            buttonsStackView.addArrangedSubview(buttonView)
        }

        let stackView = UIStackView(arrangedSubviews: [headerStackView, buttonsStackView, UIView()])
        stackView.axis = .vertical
        stackView.spacing = 70

        let scrollView = UIScrollView()
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createButtonView(menuItem: MenuItem) -> UIView {
        let label = UILabel()
        label.font = .nn_font(type: .regular, sizeFont: 24)
        label.textColor = .nn_turquoise
        label.textAlignment = .right
        label.text = menuItem.title

        let imageViewBackground = UIView()
        imageViewBackground.backgroundColor = MenuViewController.menuBackgroundColor
        imageViewBackground.nn_roundAllCorners(radius: .value(10))

        let imageView = UIImageView()
        imageView.image = menuItem.image
        imageView.contentMode = .center
        imageViewBackground.addSubview(imageView)
        imageView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
        }

        let imageViewBackgroundGradient = imageViewBackground.nn_wrappedWithGradientView()
        imageViewBackgroundGradient.contentMargins = .init(top: 4, left: 4, bottom: 4, right: 4)
        imageViewBackgroundGradient.nn_roundAllCorners(radius: .value(12))
        imageViewBackgroundGradient.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
        }

        let stackView = UIStackView(arrangedSubviews: [UIView(), label, imageViewBackgroundGradient])
        stackView.axis = .horizontal
        stackView.spacing = 18
        stackView.distribution = .fill

        return stackView
    }

    @objc private func onClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

    @objc private func onOptionSelected(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, let menuItem = self.viewModel.menu[safe: index] else {
            return
        }

        self.dismiss(animated: false) { [weak self] in
            self?.onMenuItem?(menuItem)
        }
    }
}
