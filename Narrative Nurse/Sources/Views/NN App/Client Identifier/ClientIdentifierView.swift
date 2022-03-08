//
//  CientIdentifierView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 15.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class ClientIdentifierView: UIView {
    
    private let roomIdentityView = RoomNumberView()
    private let emojiView = EmojiView()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [self.roomIdentityView, self.emojiView])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.insetsLayoutMarginsFromSafeArea = false
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func update(with identifier: ClientIdentifier) {
        switch identifier {
        case .room(number: let number, section: let section):
            self.roomIdentityView.update(number: String(number), section: section.title)
            self.roomIdentityView.isHidden = false
            self.emojiView.isHidden = true
        case .emoji(emoji: let emoji):
            self.emojiView.update(emoji: emoji)
            self.roomIdentityView.isHidden = true
            self.emojiView.isHidden = false
        }
    }
}
