//
//  ImageOptionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 22.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AnswerImageOptionTableViewCell: UITableViewCell, AnswerOptionCell {

    private let titleTextField = BuilderTextField()
    private let polygonTextField = BuilderTextField()
    private let narrativeTextField = BuilderTextField()

    private var option: Option?

    var editedOption: Option? {
        guard let option = self.option else { return nil }
        return Option(kind: .polygon(polygon: (self.polygonTextField.text ?? "").components(separatedBy: ", ").compactMap({ $0.convertToDouble() }), title: self.titleTextField.text ?? ""), narrative: self.narrativeTextField.text ?? option.narrative, id: option.id)
    }

    var onEdit: VoidClosure?

     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)

           self.setupViews()
       }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOption(_ option: Option) {
        self.option = option
        self.updateViews()
    }

    private func setupViews() {
        self.titleTextField.placeholder = "Title"
        self.titleTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.titleTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)

        self.polygonTextField.placeholder = "Polygon"
        self.polygonTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)
        self.polygonTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        self.narrativeTextField.placeholder = "Narrative"
        self.narrativeTextField.addTarget(self, action: #selector(self.onTextEdited), for: .editingChanged)
        self.narrativeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stackView = UIStackView(arrangedSubviews: [self.titleTextField, self.polygonTextField, self.narrativeTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        self.contentView.nn_addSubview(stackView)
    }

    private func updateViews() {
        guard let option = self.option, case Option.Kind.polygon(let polygon, _) = option.kind else { return }

        self.titleTextField.text = option.kind.title
        self.polygonTextField.text = polygon.compactMap({"\($0)"}).joined(separator: ", ")
        self.narrativeTextField.text = option.narrative
    }

    @objc private func onTextEdited() {
        self.onEdit?()
    }
}

fileprivate extension String {

    func convertToDouble() -> Double {
        if let number = NumberFormatter().number(from: self) {
            return Double(truncating: number)
        }
        return 0
    }
}
