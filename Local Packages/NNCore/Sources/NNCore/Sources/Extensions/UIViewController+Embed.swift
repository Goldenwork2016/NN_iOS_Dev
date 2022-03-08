//
//  UIViewController+Embed.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIViewController {

    func nn_embed(viewController: UIViewController, layoutConstraints: UIView.LayoutConstraintsSetupClosure = UIView.nn_constraintsCoverFull) {
        nn_embed(viewController: viewController, view: self.view, layoutConstraints: layoutConstraints)
    }

    func nn_embed(viewController: UIViewController, view: UIView, layoutConstraints: UIView.LayoutConstraintsSetupClosure = UIView.nn_constraintsCoverFull) {
        guard viewController.parent !== self else { return }

        self.addChild(viewController)
        viewController.view.preservesSuperviewLayoutMargins = true
        view.nn_addSubview(viewController.view, layoutConstraints: layoutConstraints)
        viewController.didMove(toParent: self)
    }

    func nn_unembedSelf() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
