//
//  AppDelegate+Appearance.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 18.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

extension AppDelegate {

    func setupAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = .nn_lightBlue
        navigationBarAppearance.backgroundColor = .nn_lightGray
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.shadowImage =  UIImage.withColor(color: .nn_midGray, height: 2)
        navigationBarAppearance.setBackgroundImage(UIImage.withColor(color: .nn_lightGray), for: .default)

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.nn_font(type: .regular, sizeFont: 21),
            NSAttributedString.Key.foregroundColor: UIColor.nn_lightBlue],
        for: .normal)
    }

}
