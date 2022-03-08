//
//  NNModalViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 23.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

class NNModalViewController: UIViewController {

    let containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        self.containerView.backgroundColor = .nn_lightGray
        self.containerView.nn_roundTopCorners(radius: .value(37))

        self.view.nn_addSubview(self.containerView)
    }

}
