//
//  QuestionsViewController.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 12.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore
import Appodeal

final class QuestionsViewController: BaseViewController {

    private static var hasCashedBanner = false

    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let coverView = UIView()
    private var resultsPreviewViewLeadingConstraint: NSLayoutConstraint!
    private var initialResultsPreviewGestureTouchPoint: CGPoint?
    private let nextButton = NNButton()
    private let previewButton = NNButton()
    private let menuView = NNDropdownMenuView()
    private var footerView = FooterView()

    let viewModel: QuestionsViewModel

    var onComplete: (([Question], [Answer]) -> Void)?
    var onNotePreview: StringClosure?
    var onFeedback: VoidClosure?

    private var bottomConstraint: NSLayoutConstraint?
    private var isDisplayingBanner: Bool = QuestionsViewController.hasCashedBanner

    init(viewModel: QuestionsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.viewModel.onComplete = { [weak self] answers in
            guard let sself = self else { return }

            if Appodeal.isReadyToShow(place: .beforeResult) {
                Appodeal.setInterstitialDelegate(self)
                Appodeal.showAd(place: .beforeResult, in: sself)
            } else {
                sself.onComplete?(sself.viewModel.questions, answers)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.shared.logEvent(Event.sequenceStart)

        self.setupViews()
        self.showAd()
        self.updateBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.collectionView.reloadData()
        self.viewModel.removeLastAnswer()

        self.scrollToLastQuestion()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.bottomConstraint?.constant = self.isDisplayingBanner ? -40 : 0
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateBackButton() {
        if self.viewModel.getNumberOfQuestions() > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backButtonPressed))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    private func showAd() {
        Appodeal.setBannerDelegate(self)
        Appodeal.showAd(place: .sequence, in: self)
    }

    private func setupViews() {
        self.view.backgroundColor = .nn_lightGray

        let menuItemContainerView = MenuItemContainerView()
        menuItemContainerView.addItem(with: "Make a suggestion about this question.", closure: { [weak self] in
            self?.onFeedback?()
            self?.menuView.switchState()
        })

        self.menuView.itemsContainerView = menuItemContainerView
        self.navigationItem.titleView = self.menuView

        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.isScrollEnabled = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = .zero
        self.collectionView.register(QuestionsEmptyCell.self, forCellWithReuseIdentifier: QuestionsEmptyCell.className)
        self.collectionView.register(QuestionsListCell.self, forCellWithReuseIdentifier: QuestionsListCell.className)
        self.collectionView.register(QuestionsImageCell.self, forCellWithReuseIdentifier: QuestionsImageCell.className)
        self.collectionView.register(QuestionsDateTimeCell.self, forCellWithReuseIdentifier: QuestionsDateTimeCell.className)
        self.collectionView.register(QuestionsSizeCell.self, forCellWithReuseIdentifier: QuestionsSizeCell.className)
        self.collectionView.register(QuestionsGroupedCell.self, forCellWithReuseIdentifier: QuestionsGroupedCell.className)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.nextButton.setTitle("Next", for: .normal)
        self.nextButton.isHidden = true
        self.nextButton.addTarget(self, action: #selector(self.nextButtonPressed), for: .touchUpInside)

        self.previewButton.setImage(Assets.resultPreview.image, for: .normal)
        self.previewButton.addTarget(self, action: #selector(self.showPreviewPressed), for: .touchUpInside)
        self.previewButton.tintColor = .nn_orange
        
        let clientIdentifierView = ClientIdentifierView()
        clientIdentifierView.update(with: self.viewModel.clientIdentifier)
        clientIdentifierView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        self.footerView.leadingView = self.previewButton
        self.footerView.trailingView = self.nextButton
        self.footerView.centerView = clientIdentifierView
        self.footerView.heightAnchor.constraint(equalToConstant: 103).isActive = true

        let collectionViewContainer = UIView()
        collectionViewContainer.nn_addSubview(self.collectionView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 10)
            ]
        }

        let stackView = UIStackView(arrangedSubviews: [menuItemContainerView, collectionViewContainer, self.footerView])
        stackView.axis = .vertical
        stackView.spacing = 0
        self.view.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            let constraint = view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            self.bottomConstraint = constraint
            return [
                view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
                constraint
            ]
        }

        self.coverView.backgroundColor = UIColor.clear
        self.coverView.isHidden = true
        self.view.nn_addSubview(self.coverView)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.cancelButtonPressed))
    }

    @objc private func nextButtonPressed() {
        let center = self.view.convert(self.view.center, to: self.collectionView)
        guard let index = self.collectionView.indexPathForItem(at: center),
              let cell = self.collectionView.cellForItem(at: index) as? QuestionsBaseCell else {
            return
        }

        let selectedOptions = cell.getSelectedOptions()

        assert(!selectedOptions.isEmpty, "Can't be empty!")

        self.viewModel.addAnswer(options: selectedOptions)
        self.collectionView.reloadData()
        self.scrollToNextIfAvailable(cell: cell)
        cell.logTimeSpentForQuestion()
    }

    @objc private func showPreviewPressed() {
        self.onNotePreview?(self.viewModel.narrative)
    }

    @objc private func backButtonPressed() {
        self.scrollToPreviousIfAvailable()

        self.viewModel.removeLastQuestion()
        self.collectionView.reloadData()
        self.updateBackButton()
    }

    @objc private func cancelButtonPressed() {
        let alert = UIAlertController(title: nil, message: "Do you want to save your progress?", preferredStyle: .alert)
        alert.addAction(.init(title: "Yes", style: .default, handler: { _ in
            Analytics.shared.logEvent(Event.sequenceCancel)
            self.viewModel.save()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(.init(title: "No", style: .default, handler: { _ in
            Analytics.shared.logEvent(Event.sequenceCancel)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func blockUserInteraction() {
        self.coverView.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] (_) in
            self?.coverView.isHidden = true
        }
    }

    private func scrollToNextIfAvailable(cell: UICollectionViewCell) {
        self.blockUserInteraction()

        let offsetX: CGFloat = cell.frame.origin.x + cell.frame.width
        let offsetY: CGFloat = 0

        self.collectionView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
        self.updateBackButton()
    }

    private func scrollToPreviousIfAvailable() {
        self.blockUserInteraction()

        let offsetX: CGFloat = self.collectionView.contentSize.width - 3 * self.collectionView.frame.width
        let offsetY: CGFloat = 0

        self.collectionView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
        self.updateBackButton()
    }

    private func scrollToLastQuestion() {
        self.blockUserInteraction()
        self.updateBackButton()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let offsetX: CGFloat = self.collectionView.contentSize.width - 2 * self.collectionView.frame.width
            let offsetY: CGFloat = 0

            self.collectionView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
        }
    }

    private func cellReuseIdentifier(for kind: Question.Kind) -> String {
        switch kind {
        case .list:
            return QuestionsListCell.className
        case .image:
            return QuestionsImageCell.className
        case .grouped:
            return QuestionsGroupedCell.className
        case .dateTime:
            return QuestionsDateTimeCell.className
        case .size:
            return QuestionsSizeCell.className
        default:
            return QuestionsListCell.className
        }
    }
}

// MARK: - UICollectionViewDataSource
extension QuestionsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfQuestions() + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let question = self.viewModel.getQuestion(at: indexPath.item),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier(for: question.kind), for: indexPath) as? QuestionsBaseCell else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestionsEmptyCell.className, for: indexPath) as? QuestionsEmptyCell else { return UICollectionViewCell() }

            return cell
        }

        cell.setQuestion(question, isFirstQuestion: indexPath.item == 0)
        cell.onNext = { [weak self] in
            self?.nextButtonPressed()
        }
        cell.onReadyToGoNext = { [weak self] readyToGoNext in
            self?.nextButton.isHidden = !readyToGoNext
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension QuestionsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

// MARK: - UICollectionViewDelegate
extension QuestionsViewController: AppodealInterstitialDelegate {

    func interstitialDidDismiss() {
        self.onComplete?(self.viewModel.questions, self.viewModel.answers)
    }

}

// MARK: - AppodealBannerDelegate
extension QuestionsViewController: AppodealBannerDelegate {
    func bannerDidShow() {
        QuestionsViewController.hasCashedBanner = true
        self.isDisplayingBanner = true
        self.view.setNeedsLayout()
    }

    func bannerDidLoadAdIsPrecache(_ precache: Bool) {
        QuestionsViewController.hasCashedBanner = true
        self.isDisplayingBanner = true
        self.view.setNeedsLayout()
    }

    func bannerDidExpired() {
        self.isDisplayingBanner = false
        self.view.setNeedsLayout()
    }

    func bannerDidFailToLoadAd() {
        self.isDisplayingBanner = false
        self.view.setNeedsLayout()
    }
}
