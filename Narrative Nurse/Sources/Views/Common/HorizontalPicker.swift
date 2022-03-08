//
//  YearPicker.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class HorizontalPicker: UIView {

    private let pickerView = AKPickerView(frame: .zero)
    private(set) var items: [String] = []
    var selectedItem: String {
        return self.items[self.pickerView.selectedItem]
    }
    var selectedItemIndex: Int {
        return self.pickerView.selectedItem
    }
    var onSelect: StringClosure?
    var font: UIFont {
        set {
            self.pickerView.font = newValue
            self.pickerView.highlightedFont = newValue
        }
        get {
            return self.pickerView.font
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

    func setItems(_ items: [String]) {
        self.items = items
        self.pickerView.reloadData()
    }

    func selectItem(at index: Int, animated: Bool) {
        self.pickerView.selectItem(index, animated: animated)
    }

    private func setupView() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.interitemSpacing = 20
        self.pickerView.textColor = .nn_lightBlue
        self.pickerView.highlightedTextColor = .nn_orange
        self.pickerView.pickerViewStyle = .flat
        self.pickerView.maskDisabled = true
        self.pickerView.minWidth = 90

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
