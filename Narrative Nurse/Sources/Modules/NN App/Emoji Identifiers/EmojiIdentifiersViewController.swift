//
//  SelectEmojiViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 14.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit
import NNCore

final class EmojiIdentifiersViewController: UIViewController {
    let viewModel: EmojiIdentifiersViewModel
    
    private let nextButton = NNButton()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        return collectionView
    }()
    
    var onNext: VoidClosure?
    
    init(viewModel: EmojiIdentifiersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    private func updateView() {
        self.viewModel.loadSelectedEmojies()
        self.collectionView.reloadData()
        self.nextButton.isHidden = self.viewModel.noSelectedIdentiers
    }
    
    private func setupView() {
        let navigationView = NNNavigationView()
        navigationView.title = "Select Identifiers"
        navigationView.isMenuButtonHidden = true
        navigationView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.collectionView.backgroundColor = .nn_lightGray
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = true
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        self.collectionView.register(EmojiIdentifierCell.self, forCellWithReuseIdentifier: EmojiIdentifierCell.className)
        collectionView.register(EmojiIdentifiersFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: EmojiIdentifiersFooterView.className)
        
        self.nextButton.setTitle("Next", for: .normal)
        self.nextButton.backgroundColor = .white
        self.nextButton.addTarget(self, action: #selector(self.onNextClicked), for: .touchUpInside)
        
        let nextButtonContainer = UIView()
        nextButtonContainer.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let buttonsStackView = UIStackView(arrangedSubviews: [nextButtonContainer])
        buttonsStackView.layoutMargins = .init(top: 8, left: 0, bottom: 24, right: 0)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        buttonsStackView.insetsLayoutMarginsFromSafeArea = false
        buttonsStackView.distribution = .fill
        
        let stackView = UIStackView(arrangedSubviews: [navigationView, self.collectionView, buttonsStackView])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.spacing = 0
        stackView.axis = .vertical
        
        self.view.backgroundColor = .white
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension EmojiIdentifiersViewController {
    
    @objc private func onNextClicked() {
        self.viewModel.saveSelectedEmojie()
        self.onNext?()
        self.viewModel.showAllEmojies = false
    }
    
}

// MARK: - UITableViewDataSource
extension EmojiIdentifiersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.countOfEmojies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let emojieCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: EmojiIdentifierCell.className, for: indexPath) as? EmojiIdentifierCell,
              let emojie = self.viewModel.getEmojie(at: indexPath.row) else {
            return UICollectionViewCell()
        }
        
        emojieCell.isSelected = self.viewModel.isSelected(at: indexPath.row)
        emojieCell.update(emoji: emojie)
        
        return emojieCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiIdentifiersFooterView.className, for: indexPath)
            headerView.isUserInteractionEnabled = !self.viewModel.showAllEmojies
            headerView.isHidden = self.viewModel.showAllEmojies
            if let headerView = headerView as? EmojiIdentifiersFooterView {
                headerView.onMore = { [weak self] in
                    self?.viewModel.showAllEmojies = true
                    self?.collectionView.reloadData()
                }
            }
            return headerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension EmojiIdentifiersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let cellsInTheRow: CGFloat = 4.0
        let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: section))
        let contentAreaWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let spacing = (contentAreaWidth - cellSize.width * cellsInTheRow)/(cellsInTheRow - 1)
        let roundedSpacing = Int(spacing)
        return CGFloat(roundedSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.switchSelectedState(at: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: false)
        updateView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = self.viewModel.showAllEmojies ? 0 : 100.0
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}
