//
//  UIApplication+KeyWindow.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 12.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIApplication {

    var nn_keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map {$0 as? UIWindowScene}
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }

}
