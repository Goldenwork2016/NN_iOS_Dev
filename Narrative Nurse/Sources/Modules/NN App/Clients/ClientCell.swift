//
//  ClientCell.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class ClientCell: UITableViewCell {
    
    enum PreviewStyle {
        case none
        case unfinishedSequence
        case noteHistory
    }
    
    private let identifierView = ClientIdentifierView()
    private let previewButton = UIButton()
    
    var onStart: VoidClosure?
    var onPreview: VoidClosure?
    var onDelete: VoidClosure?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        let arrowRightButton = UIButton()
        arrowRightButton.setImage(Assets.arrowRight.image, for: .normal)
        arrowRightButton.addTarget(self, action: #selector(self.onArrowRightClicked), for: .touchUpInside)
        arrowRightButton.imageView?.contentMode = .scaleAspectFit
        arrowRightButton.contentVerticalAlignment = .fill
        arrowRightButton.contentHorizontalAlignment = .fill
        arrowRightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        arrowRightButton.snp.makeConstraints { make in
            make.width.equalTo(61)
        }
        
        self.previewButton.setImage(Assets.resultPreview.image, for: .normal)
        self.previewButton.addTarget(self, action: #selector(self.onPreviewClicked), for: .touchUpInside)
        self.previewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.previewButton.imageView?.contentMode = .scaleAspectFit
        self.previewButton.contentVerticalAlignment = .fill
        self.previewButton.contentHorizontalAlignment = .fill
        self.previewButton.snp.makeConstraints { make in
            make.width.equalTo(69)
        }
        
        let buttonsStackView = UIStackView(arrangedSubviews: [self.previewButton, arrowRightButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.spacing = 26
        
        let stackView = UIStackView(arrangedSubviews: [self.identifierView, UIView(), buttonsStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        
        let selectableButton = NNSelectableButton()
        selectableButton.isSelected = true
        
        selectableButton.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(selectableButton)
        selectableButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15))
        }
        
        
        let onLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        stackView.addGestureRecognizer(onLongPressGesture)
    }
    
    @objc private func onLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete the saved client?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            self.onDelete?()
        }))

        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func onArrowRightClicked() {
        self.onStart?()
    }
    
    @objc private func onPreviewClicked() {
        self.onPreview?()
    }
    
    func update(clientIdentifier: ClientIdentifier, preview: PreviewStyle) {
        self.identifierView.update(with: clientIdentifier)
        
        switch preview {
        case .none:
            self.previewButton.isHidden = true
        case .noteHistory:
            self.previewButton.isHidden = false
            self.previewButton.tintColor = .nn_lightBlue
        case .unfinishedSequence:
            self.previewButton.isHidden = false
            self.previewButton.tintColor = .nn_orange
        }
    }
}
