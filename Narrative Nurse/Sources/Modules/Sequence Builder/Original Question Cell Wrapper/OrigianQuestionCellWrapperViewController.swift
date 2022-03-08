//
//  OrigianQuestionCellWrapperViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 12.10.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class OrigianQuestionCellWrapperViewController: UIViewController {
    
    let viewModel: OrigianQuestionCellWrapperViewModel
    private var onOptions: OptionsClosure?
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    init(viewModel: OrigianQuestionCellWrapperViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .nn_lightGray
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onClose))

        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.isScrollEnabled = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = .zero
        self.collectionView.register(QuestionsImageCell.self, forCellWithReuseIdentifier: QuestionsImageCell.className)
        self.collectionView.register(QuestionsDateTimeCell.self, forCellWithReuseIdentifier: QuestionsDateTimeCell.className)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.view.nn_addSubview(self.collectionView)
    }
    
    @objc private func onDone() {
        self.dismiss(animated: true, completion: nil)
        
        if let questionCellView = self.collectionView.cellForItem(at: .init(row: 0, section: 0)) as? QuestionsBaseCell {
            self.onOptions?(questionCellView.getSelectedOptions())
        }
    }
    
    @objc private func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func cellReuseIdentifier(for kind: Question.Kind) -> String {
        switch kind {
        case .list:
             fatalError("Not supported")
        case .image:
            return QuestionsImageCell.className
        case .grouped:
             fatalError("Not supported")
        case .dateTime:
            return QuestionsDateTimeCell.className
        case .size:
             fatalError("Not supported")
        default:
             fatalError("Not supported")
        }
    }
}

//MARK: - UICollectionViewDataSource
extension OrigianQuestionCellWrapperViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let question = self.viewModel.question
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier(for: question.kind), for: indexPath) as? QuestionsBaseCell else {
            return UICollectionViewCell()
        }
        
        cell.setQuestion(question, isFirstQuestion: indexPath.item == 0)
        cell.onReadyToGoNext = { [weak self] readyToGoNext in
            guard let sself = self else { return }
            
            if readyToGoNext {
                sself.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: sself, action: #selector(sself.onDone))
            } else {
                sself.navigationItem.rightBarButtonItem = nil
            }
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension OrigianQuestionCellWrapperViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension OrigianQuestionCellWrapperViewController {
    
    static func instantiate(with question: Question, onOptions: @escaping OptionsClosure) -> UINavigationController {
        let viewModel = OrigianQuestionCellWrapperViewModel(question: question)
        let viewController = OrigianQuestionCellWrapperViewController(viewModel: viewModel)
        viewController.onOptions = onOptions
        
        let nc = UINavigationController(rootViewController: viewController)
        
        return nc
    }
    
}

