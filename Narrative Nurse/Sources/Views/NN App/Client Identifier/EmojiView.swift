//
//  EmojieView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 14.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class EmojiView: UIView {
    
    private let emojiLabel = UILabel()
    private let backgroundView = UIView()
    
    var isBackgroundHidden: Bool {
        set {
            self.backgroundView.isHidden = newValue
        }
        get {
            return self.backgroundView.isHidden
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
        self.backgroundView.backgroundColor = .white
        self.backgroundView.layer.borderWidth = 1.0
        self.backgroundView.layer.borderColor = UIColor.nn_midGray.cgColor
        self.backgroundView.nn_roundAllCorners(radius: .value(16))
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emojiLabel.font = .nn_font(type: .bold, sizeFont: 46)
        self.emojiLabel.textAlignment = .center
        
        self.addSubview(self.emojiLabel)
        self.emojiLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.emojiLabel.snp.height)
        }
    }
    
    func update(emoji: Emoji) {
        self.emojiLabel.text = emoji
    }
}
