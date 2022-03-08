//
//  DuplicateSequenceViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 17.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore
import UIKit

final class SequenceSelectorViewController: UIViewController {
    
    private lazy var segmentedControl: UISegmentedControl = {
        let titles = self.subcontrollers.map { $0.viewModel.source.title }
        return UISegmentedControl(items: titles)
    }()
    private let containerView = UIView()
    
    let viewModel: SequenceSelectorViewModel
    let subcontrollers: [SequencesListViewController]
    
    var onSequence: ((URL, SequenceFileType) -> Void)? {
        set {
            self.subcontrollers.forEach { $0.onSequence = newValue }
        }
        get {
            return self.subcontrollers.first?.onSequence
        }
    }
    
    init(viewModel: SequenceSelectorViewModel, subcontrollers: [SequencesListViewController]) {
        self.viewModel = viewModel
        self.subcontrollers = subcontrollers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        selectView(with: self.segmentedControl.selectedSegmentIndex)
    }
    
    private func setupView() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.addTarget(self, action: #selector(self.onSegmentedControlChanged), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [self.segmentedControl, self.containerView])
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.view.backgroundColor = .white
        self.view.nn_addSubview(stackView)
    }

    @objc private func onSegmentedControlChanged() {
        self.selectView(with: self.segmentedControl.selectedSegmentIndex)
    }
    
    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }

    private func selectView(with index: Int) {
        for (i, vc) in self.subcontrollers.enumerated() {
            if index == i {
                self.nn_embed(viewController: vc, view: self.containerView)
            } else {
                vc.nn_unembedSelf()
            }
        }
    }
}

