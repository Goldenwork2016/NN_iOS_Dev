//
//  UIView+Embed.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIView {

    typealias LayoutConstraintsSetupClosure = (UIView, UIView) -> [NSLayoutConstraint]

    static var nn_constraintsCoverFull: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ]
    }

    static var nn_constraintsCoverToLayoutMargins: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ]
    }

    static var nn_constraintsCenterVerticallyAndStickHorizontallyToLayoutMargins: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ]
    }

    static var nn_constraintsCenter: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ]
    }

    static var nn_constraintsHorizontallyCenteredAtBottomMargin: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ]
    }

    static var nn_constraintsAtTop: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor)
        ]
    }

    static var nn_constraintsAtBottom: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ]
    }

    static var nn_constraintsAtTopLayoutMargins: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.bottomAnchor)
        ]
    }

    static var nn_constraintsAtBottomLayoutMargins: LayoutConstraintsSetupClosure = { (view, container) in
        [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(greaterThanOrEqualTo: container.layoutMarginsGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ]
    }

    func nn_addSubview(_ view: UIView, layoutConstraints: LayoutConstraintsSetupClosure = UIView.nn_constraintsCoverFull) {
        guard view.superview == nil else { return }

        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        let constraints = layoutConstraints(view, self)
        NSLayoutConstraint.activate(constraints)
    }
}
