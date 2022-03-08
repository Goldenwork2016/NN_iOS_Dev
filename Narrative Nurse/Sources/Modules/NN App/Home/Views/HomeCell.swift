//
//  HomeCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 20.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class HomeCell: UITableViewCell {

    private let selectableButton = NNSelectableButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }
    
    var onSelected: VoidClosure?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selectableButton.isSelected = false
        self.selectableButton.title = nil
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.selectableButton.addTarget(self, action: #selector(onTapOnButton), for: .touchUpInside)
        self.selectableButton.button.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)

        self.contentView.addSubview(self.selectableButton)
        self.selectableButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
    }
    
    @objc private func onTapOnButton() {
        self.selectableButton.isSelected = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] timer in
            self?.onSelected?()
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
                self?.selectableButton.isSelected = false
            }
        }
    }
    
    func update(title: String) {
        self.selectableButton.title = title
    }
}


