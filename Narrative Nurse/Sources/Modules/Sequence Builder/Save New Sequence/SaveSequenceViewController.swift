//
//  SaveSequenceViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 18.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SaveSequenceViewController: UIViewController {

    let viewModel: SaveSequenceViewModel

    var onSaved: URLClosure?

    init(viewModel: SaveSequenceViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showSaveDialog()
    }

    private func showSaveDialog() {
        let alertController = UIAlertController.textFieldAlert(title: "Save", message: "Enter name for a new file.", okayButtonText: "Save") { [weak self] filename in
            if let filename = filename, !filename.isEmpty {
                if let newUrl = self?.viewModel.save(with: filename) {
                    self?.onSaved?(newUrl)
                }
            }
            self?.dismiss(animated: false, completion: nil)
        }

        self.present(alertController, animated: false, completion: nil)
    }

}
