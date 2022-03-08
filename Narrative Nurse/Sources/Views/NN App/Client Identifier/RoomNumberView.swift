//
//  RoomNumberView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class RoomNumberView: UIView {
    
    private let roomNumberLabel = UILabel()
    private let roomSectionLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.roomNumberLabel.textColor = .nn_lightBlue
        self.roomNumberLabel.font = .nn_font(type: .regular, sizeFont: 55)
        
        self.roomSectionLabel.textColor = .nn_orange
        self.roomSectionLabel.font = .nn_font(type: .regular, sizeFont: 47)
        
        let roomSectionContainer = UIView()
        roomSectionContainer.addSubview(self.roomSectionLabel)
        self.roomSectionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0))
        }
        
        let stackView = UIStackView(arrangedSubviews: [self.roomNumberLabel, roomSectionContainer])
        stackView.spacing = 13
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func update(number: String, section: String) {
        self.roomNumberLabel.text = number
        self.roomNumberLabel.isHidden = number.isEmpty
        
        self.roomSectionLabel.text = section
        self.roomSectionLabel.superview?.isHidden = section.isEmpty
    }
}
