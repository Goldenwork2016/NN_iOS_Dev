//
//  YearPicker.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class HorizontalPicker: UIView {

    private let pickerView = AKPickerView(frame: .zero)
    private(set) var items: [String] = []

    var onSelect: StringClosure?

    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setItems(_ items: [String]) {
        self.items = items
        self.pickerView.reloadData()
    }

    func selectItem(at index: Int, animated: Bool) {
        self.pickerView.selectItem(index, animated: animated)
    }

    private func setupView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .nn_iceBlue
        self.nn_addSubview(backgroundView)

        let selectorViewImage = UIImage(startColor: UIColor.nn_azure, endColor: UIColor.nn_brightSkyBlue)
        let selectorView = UIImageView(image: selectorViewImage)
        self.nn_addSubview(selectorView, layoutConstraints: { view, container in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.widthAnchor.constraint(equalToConstant: 70),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ]
        })

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.interitemSpacing = 20
        self.pickerView.textColor = .nn_marineBlue
        self.pickerView.highlightedTextColor = .nn_label
        self.pickerView.font = .systemFont(ofSize: 17, weight: .regular)
        self.pickerView.highlightedFont = .systemFont(ofSize: 17, weight: .bold)
        self.pickerView.pickerViewStyle = .flat
        self.pickerView.maskDisabled = true

        self.nn_addSubview(self.pickerView)
    }
}

// MARK: - AKPickerView
extension HorizontalPicker: AKPickerViewDataSource, AKPickerViewDelegate {

    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.items.count
    }

    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.items[item]
    }

    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        self.onSelect?(self.items[item])
    }

}
