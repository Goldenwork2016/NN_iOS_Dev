//
//  File.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class RoomsCell: UITableViewCell {
    
    private let numberLabel = UILabel()
    private var sectionLabels: [RoomSection: UILabel] = [:]
    
    var onDelete: VoidClosure?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    private func setupViews() {
        let selectableButton = NNSelectableButton()
        selectableButton.isSelected = true
        selectableButton.title = nil
        
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.contentView.addSubview(selectableButton)
        selectableButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 27, bottom: 8, right: 24)
        
        self.numberLabel.font = .nn_font(type: .regular, sizeFont: 48)
        self.numberLabel.textColor = .nn_lightBlue
        stackView.addArrangedSubview(self.numberLabel)
        
        for section in RoomSection.allCases {
            let sectionLabel = UILabel()
            sectionLabel.font = .nn_font(type: .regular, sizeFont: 44)
            sectionLabel.textColor = .nn_orange
            sectionLabel.text = section.title
            
            let sectionLabelContainer = UIView()
            sectionLabelContainer.addSubview(sectionLabel)
            sectionLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                    .inset(UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
            }
            
            stackView.addArrangedSubview(sectionLabelContainer)
            self.sectionLabels[section] = sectionLabel
        }
        
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
        
        let onLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        stackView.addGestureRecognizer(onLongPressGesture)
    }
    
    
    func update(with number: Int, and sections: [RoomSection]) {
        self.numberLabel.text = "\(number)"
        for sectionLabel in  self.sectionLabels {
            let isAvailable = sections.contains(sectionLabel.key)
            sectionLabel.value.alpha = isAvailable ? 1.0 : 0.0
        }
    }
    
    @objc private func onLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete the saved room?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            self.onDelete?()
        }))

        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
