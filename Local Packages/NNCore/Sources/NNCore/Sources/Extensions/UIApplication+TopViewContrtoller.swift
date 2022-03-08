//
//  UIApplication+TopViewContrtoller.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 20.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIApplication {
    /// Returns the currently top-most view controller.
    class func topViewController(base: UIViewController? = UIApplication.shared.nn_keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    /// Show `viewController` over the top-most view controller.
    class func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            topViewController()?.present(viewController, animated: animated, completion: completion)
        }
    }
}
