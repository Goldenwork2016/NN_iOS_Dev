//
//  SentenceTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 30.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class NoteHistoryTableViewCell: UITableViewCell {

    private let identifierView = ClientIdentifierView()
    private let timeLabel = UILabel()
    
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
        
        self.timeLabel.font = .nn_font(type: .regular, sizeFont: 36)
        self.timeLabel.textColor = .nn_orange
        self.timeLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [self.identifierView, self.timeLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        
        let selectableButton = NNSelectableButton()
        selectableButton.isSelected = true
        
        selectableButton.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(selectableButton)
        selectableButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }
    
    func update(clientIdentifier: ClientIdentifier, date: Date) {
        self.identifierView.update(with: clientIdentifier)
        
        let timeFormatter = NNDateFormatter(format: "h:mm a")
        self.timeLabel.text = timeFormatter.string(from: date)
    }
}
