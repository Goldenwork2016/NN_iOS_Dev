//
//  AddRoomViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 10.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class AddRoomViewController: NNModalViewController {
    
    let viewModel: AddRoomViewModel
    
    var onConfirm: BoolClosure?
    
    private lazy var roomSectionsStackView: UIStackView = setupRoomSectionButtons()
    private let enteredRoomView = RoomNumberView()
    private let confirmButton = NNButton()
    private let notificationLabel = UILabel()
    
    init(viewModel: AddRoomViewModel) {
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
        updateUI()
    }
    
    private func updateUI() {
        self.roomSectionsStackView.arrangedSubviews
            .compactMap { $0 as? NNSelectableButton }
            .forEach { $0.isSelected = self.viewModel.isRoomSectionSelected(at: $0.tag) }
        
        self.enteredRoomView.update(number: self.viewModel.roomNumber, section: self.viewModel.selectedRoomSectionsString)
        self.confirmButton.isHidden = !self.viewModel.isValidRoomNumber
    }

}

// MARK: - Setup
extension AddRoomViewController {
    
    private func setupViews() {
        let titleLabel = setupTitleView()
        
        let enteredRoomNumberContainer = UIView()
        enteredRoomNumberContainer.backgroundColor = .white
        enteredRoomNumberContainer.snp.makeConstraints { make in
            make.height.equalTo(69)
        }
        
        enteredRoomNumberContainer.addSubview(self.enteredRoomView)
        self.enteredRoomView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let keypadView = setupKeypadView()
        
        let bottomButtons = setupBottomButtons()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, enteredRoomNumberContainer, keypadView, bottomButtons])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.spacing = 0
        stackView.axis = .vertical
        
        self.containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTitleView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .nn_font(type: .bold, sizeFont: 40)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "Add Rooms"
        let titleGradientView = titleLabel.nn_wrappedWithGradientView(contentMargins: .init(top: 22, left: 30, bottom: 30, right: 30))
        
        return titleGradientView
    }
    
    private func setupBottomButtons() -> UIView {
        let closeButton = NNButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .white
        closeButton.addTarget(self, action: #selector(self.onCloseClicked), for: .touchUpInside)

        self.confirmButton.setTitle("Confirm", for: .normal)
        self.confirmButton.backgroundColor = .white
        self.confirmButton.addTarget(self, action: #selector(self.onConfirmClicked), for: .touchUpInside)
        
        let confirmButtonContainer = UIView()
        confirmButtonContainer.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let okayButtonStackView = UIStackView(arrangedSubviews: [closeButton, confirmButtonContainer])
        okayButtonStackView.layoutMargins = .init(top: 8, left: 0, bottom: 24, right: 0)
        okayButtonStackView.isLayoutMarginsRelativeArrangement = true
        okayButtonStackView.insetsLayoutMarginsFromSafeArea = false
        okayButtonStackView.backgroundColor = .white
        okayButtonStackView.distribution = .fillEqually
        
        setupNotificationLabel()
        okayButtonStackView.addSubview(self.notificationLabel)
        self.notificationLabel.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(okayButtonStackView.snp.top).offset(-16)
        }
        
        return okayButtonStackView
    }
    
    private func setupNotificationLabel() {
        self.notificationLabel.font = .nn_font(type: .bold, sizeFont: 24)
        self.notificationLabel.textAlignment = .center
        self.notificationLabel.textColor = .nn_orange
        self.notificationLabel.text = "Rooms Added"
        self.notificationLabel.nn_roundAllCorners(radius: .value(19))
        self.notificationLabel.isHidden = true
    }
    
    private func setupKeypadView() -> UIView {
        let keypadView = NNKeypadView()
        keypadView.isDotHidden = true
        keypadView.onClear = { [weak self] in
            self?.viewModel.clear()
            self?.updateUI()
        }
        keypadView.onNumber = { [weak self] value in
            self?.viewModel.addRoomNumber(value)
            self?.updateUI()
        }
        
        let keyPadConteinerStackView = UIStackView(arrangedSubviews: [keypadView, self.roomSectionsStackView])
        keyPadConteinerStackView.axis = .vertical
        keyPadConteinerStackView.layoutMargins = .init(top: 50, left: 35, bottom: 30, right: 35)
        keyPadConteinerStackView.isLayoutMarginsRelativeArrangement = true
        keyPadConteinerStackView.spacing = 40
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.backgroundColor = .nn_lightGray
        scrollView.addSubview(keyPadConteinerStackView)
        keyPadConteinerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        return scrollView
    }
    
    private func setupRoomSectionButtons() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 17
        stackView.axis = .horizontal
        
        for i in 0..<self.viewModel.roomSections.count {
            let button = NNSelectableButton()
            button.title = self.viewModel.roomSections[i].title
            button.tag = i
            button.addTarget(self, action: #selector(onRoomSectionClicked(button:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(button.snp.width)
            }
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
}

// MARK: - Actions
extension AddRoomViewController {
    
    @objc private func onCloseClicked() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.onConfirm?(false)
        })
    }

    @objc private func onConfirmClicked() {
        self.confirmButton.isUserInteractionEnabled = false
        self.viewModel.save()
        self.notificationLabel.isHidden = false
        self.onConfirm?(true)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [self] _ in
            self.notificationLabel.isHidden = true
            self.viewModel.clear()
            self.confirmButton.isUserInteractionEnabled = true
            self.updateUI()
        }
    }
    
    @objc private func onRoomSectionClicked(button: UIButton) {
        self.viewModel.toogleRoomSections(at: button.tag)
        updateUI()
    }
}
