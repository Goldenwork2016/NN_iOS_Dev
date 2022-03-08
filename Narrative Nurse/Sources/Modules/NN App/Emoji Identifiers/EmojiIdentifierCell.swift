//
//  EmojiIdentifierCell.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 14.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class EmojiIdentifierCell: UICollectionViewCell {
    
    private let selectableButton = NNSelectableButton()
    private let emojiView = EmojiView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override var isSelected: Bool {
        set {
            self.emojiView.alpha = newValue ? 1.0 : 0.4
            self.selectableButton.isSelected = newValue
        }
        get {
            return self.selectableButton.isSelected
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.contentView.addSubview(self.selectableButton)
        self.selectableButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.selectableButton.isUserInteractionEnabled = false
        
        self.contentView.addSubview(self.emojiView)
        self.emojiView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emojiView.isBackgroundHidden = true
    }
    
    func update(emoji: Emoji) {
        self.emojiView.update(emoji: emoji)
    }
    
}
