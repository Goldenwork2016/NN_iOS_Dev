//
//  EmojiIdentifiersFooterView.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 14.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class EmojiIdentifiersFooterView: UICollectionReusableView {
    
    var onMore: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        let moreButton = UIButton()
        moreButton.setTitle("More", for: .normal)
        moreButton.setTitleColor(.nn_lightBlue, for: .normal)
        moreButton.titleLabel?.font = .nn_font(type: .regular, sizeFont: 24)
        self.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        moreButton.addTarget(self, action: #selector(self.onClickMore), for: .touchUpInside)
    }
    
    @objc private func onClickMore() {
        self.onMore?()
    }
}
