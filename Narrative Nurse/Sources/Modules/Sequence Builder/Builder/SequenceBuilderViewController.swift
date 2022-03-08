//
//  SequenceViewController.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 23.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SequenceBuilderViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let rightAlignedStackView = UIStackView()

    private let managementPanelView = ManagementPanelView()

    private let previewStackView = UIStackView()
    private let previewView = UIScrollView()
    private let previewLabel = UILabel()

    private var dragableView = DraggableQuestionView()
    private var separatorView = UIView()
    private var hoverView = UIView()

    private var dragableViewTopConstraint: NSLayoutConstraint?
    private var separatorViewTopConstraint: NSLayoutConstraint?
    private var separatorViewLeadingConstraint: NSLayoutConstraint?
    private var hoverViewTopConstraint: NSLayoutConstraint?
    private var hoverViewHeightConstraint: NSLayoutConstraint?

    let viewModel: SequenceBuilderViewModel

    var onSearch: ((QuestionsSequence, @escaping ((SearchQuestionTableViewModel.SearchItem) -> Void)) -> Void)?
    var onSelect: ((SequenceFileType, @escaping ((URL, SequenceFileType) -> Void)) -> Void)?
    var onSelectAnswer: ((QuestionsSequence, @escaping ((Question, Option) -> Void)) -> Void)?
    var onGlobalSettings: VoidClosure?
    var onSelectQuestions: ((@escaping (URL, SequenceFileType, [Question]) -> Void) -> Void)?

    private var hoverTimer: Timer?
    private var initialHoverLocation: CGPoint?

    init(viewModel: SequenceBuilderViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }

        self.viewModel.onUpdateNarrative = { [weak self] in
            guard let sself = self else { return }

            sself.previewLabel.text = sself.viewModel.narrative
            sself.updateNavigationBar()
        }

        self.viewModel.onUpdateSelectedQuestion = { [weak self] in
            self?.updateRightPanel()
        }

        QuestionTableViewCell.removeCache()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.updateNavigationBar()
        self.updateRightPanel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.rightAlignedStackView.layoutMargins = UIEdgeInsets(top: (-(self.navigationController?.navigationBar.frame.height ?? 0) - 20), left: 0, bottom: 0, right: 0)
    }

}

// MARK: - Others
extension SequenceBuilderViewController {

    private func cellForPoint(_ point: CGPoint) -> QuestionTableViewCell? {
        guard let indexPath = self.tableView.indexPathForRow(at: point), let cell = self.tableView.cellForRow(at: indexPath) as? QuestionTableViewCell else { return nil }

        return cell
    }

    private func presentAlert(alertController: UIAlertController, sourceView: UIView) {
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)

        self.present(alertController, animated: false, completion: nil)
    }

}

// MARK: - Setup & update view
extension SequenceBuilderViewController {

    private func setupViews() {
        self.view.backgroundColor = .white

        self.title = self.viewModel.title

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.frame = .zero
        self.tableView.register(QuestionTableViewCell.self, forCellReuseIdentifier: QuestionTableViewCell.className)

        self.tableView.dataSource = self

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)

        let tableStackView = UIStackView(arrangedSubviews: [self.tableView])
        tableStackView.isLayoutMarginsRelativeArrangement = true
        tableStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        self.managementPanelView.onPresent = { [weak self] alertController in
            guard let sself = self else { return  }
            sself.presentAlert(alertController: alertController, sourceView: sself.view)
        }
        self.managementPanelView.onPresentFileSelector = { [weak self] fileType, closure in
            guard let sself = self else { return  }

            sself.onSelect?(fileType, { (url, _) in
                closure(url)
                if let editedQuestion = sself.managementPanelView.editedQuestion {
                    self?.viewModel.updateEditedQuestion(editedQuestion)
                }
            })
        }

        self.managementPanelView.onUpdated = { [weak self] in
            guard let sself = self else { return  }

            if let editedQuestion = sself.managementPanelView.editedQuestion {
                self?.viewModel.updateEditedQuestion(editedQuestion)

                // Workaround for updating narrative
                self?.viewModel.clearAnswers(for: editedQuestion)
            }
        }

        self.managementPanelView.onReverse = { [weak self] in
            guard let sself = self,
                let question = sself.managementPanelView.editedQuestion else { return  }

            sself.viewModel.reverse(question: question)
        }

        self.managementPanelView.onSelectAnswer = { [weak self] closure in
            guard let sself = self else { return  }

            sself.onSelectAnswer?(sself.viewModel.questionsSequence, { question, option  in
                closure(question, option)
            })
        }

        let copyButton = UIImageView()
        copyButton.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            copyButton.image = UIImage(systemName: "doc.on.doc")
        }
        copyButton.isUserInteractionEnabled = true
        copyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyButtonPressed)))
        copyButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let buttonsStackView = UIStackView(arrangedSubviews: [copyButton])
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.axis = .horizontal
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        let previewTextLabel = UILabel()
        previewTextLabel.font = .preferredFont(forTextStyle: .title1)
        previewTextLabel.textColor = .black
        previewTextLabel.text = "Preview"
        previewTextLabel.textAlignment = .center

        self.previewLabel.textColor = .black
        self.previewLabel.numberOfLines = 0

        self.previewStackView.addArrangedSubview(previewTextLabel)
        self.previewStackView.addArrangedSubview(buttonsStackView)
        self.previewStackView.addArrangedSubview(self.previewLabel)
        self.previewStackView.axis = .vertical
        self.previewStackView.spacing = 20
        self.previewStackView.isLayoutMarginsRelativeArrangement = true
        self.previewStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        self.previewView.layer.borderColor = UIColor.black.cgColor
        self.previewView.layer.borderWidth = 1
        self.previewView.showsVerticalScrollIndicator = false
        self.previewView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        self.previewView.nn_addSubview(self.previewStackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor)
            ]
        }

        self.rightAlignedStackView.addArrangedSubview(self.managementPanelView)
        self.rightAlignedStackView.addArrangedSubview(self.previewView)
        self.rightAlignedStackView.isLayoutMarginsRelativeArrangement = true
        self.rightAlignedStackView.axis = .vertical
        self.rightAlignedStackView.distribution = .fillEqually

        let stackView = UIStackView(arrangedSubviews: [tableStackView, self.rightAlignedStackView])
        stackView.axis = .horizontal

        self.view.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            let bottomConstraint = KeyboardLayoutConstraint(fromItem: view, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0)
            return [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bottomConstraint,
                view.topAnchor.constraint(equalTo: container.topAnchor)
            ]
        }

        self.setupDraggableViews()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.endEditing))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func updateNavigationBar() {
        var rightButtons: [UIBarButtonItem] = []

        let items = SequenceBuilderViewModel.Mode.allCases
        let segmentedControl = UISegmentedControl(items: items.map { $0.rawValue })
        segmentedControl.selectedSegmentIndex = items.firstIndex(of: self.viewModel.mode) ?? 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        let buttonItem = UIBarButtonItem(customView: segmentedControl)
        rightButtons.append(buttonItem)

        if self.viewModel.questionsSequence.questions.isEmpty {
            rightButtons.append(UIBarButtonItem(title: "Add Question", style: .plain, target: self, action: #selector(self.addNewRootQestion)))
        } else {
            rightButtons.append(UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchPressend)))
        }


        if self.viewModel.shouldShowClearButton && self.viewModel.mode == .preview {
            rightButtons.append(UIBarButtonItem(title: "Clear All Answers", style: .plain, target: self, action: #selector(self.clearAllAnswers)))
        }

        if self.viewModel.shouldShowCollapseButton {
            rightButtons.append(UIBarButtonItem(title: "Collapse All", style: .plain, target: self, action: #selector(self.collapseAllQuestions)))
        }

        rightButtons.append(UIBarButtonItem(title: "Expand All", style: .plain, target: self, action: #selector(self.expandAllQuestions)))

        self.navigationItem.rightBarButtonItems = rightButtons

        let backButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.onBack))
        let globalSettingsButtonItem = UIBarButtonItem(title: "Global Settings", style: .plain, target: self, action: #selector(onGlobalSettingsClicked))
        self.navigationItem.leftBarButtonItems = [backButtonItem, globalSettingsButtonItem]
    }

    private func setupDraggableViews() {
        self.hoverView.backgroundColor = .systemBlue
        self.hoverView.alpha = 0.4
        self.hoverView.isHidden = true

        self.view.nn_addSubview(self.hoverView) { (view, container) -> [NSLayoutConstraint] in
            let topConstraint = view.topAnchor.constraint(equalTo: container.topAnchor)
            self.hoverViewTopConstraint = topConstraint
            let heightConstraint = view.heightAnchor.constraint(equalToConstant: 34)
            self.hoverViewHeightConstraint = heightConstraint
            return [
                topConstraint,
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                heightConstraint
            ]
        }

        self.separatorView.backgroundColor = .systemBlue
        self.separatorView.alpha = 0.4
        self.separatorView.isHidden = true

        self.view.nn_addSubview(self.separatorView) { (view, container) -> [NSLayoutConstraint] in
            let topConstraint = view.topAnchor.constraint(equalTo: container.topAnchor)
            self.separatorViewTopConstraint = topConstraint

            let leadingConstraint = view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20)
            self.separatorViewLeadingConstraint = leadingConstraint

            return [
                topConstraint,
                leadingConstraint,
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                view.heightAnchor.constraint(equalToConstant: 2)
            ]
        }

        self.dragableView.alpha = 0.5
        self.dragableView.isHidden = true

        self.view.nn_addSubview(self.dragableView) { (view, container) -> [NSLayoutConstraint] in
            let constraint = view.topAnchor.constraint(equalTo: container.topAnchor)
            self.dragableViewTopConstraint = constraint
            return [
                constraint,
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                view.heightAnchor.constraint(equalToConstant: 30)
            ]
        }
    }

    private func updateRightPanel() {
        self.managementPanelView.isHidden = true
        self.previewView.isHidden = true

        switch self.viewModel.mode {
        case .edit:
            let selectedQuestion = self.viewModel.selectedQuestion


            let isEditable: Bool
            let canReverse: Bool
            if let selectedQuestion = selectedQuestion {
                isEditable = self.viewModel.canEdit(question: selectedQuestion)
                canReverse = self.viewModel.canReverse(question: selectedQuestion)
            } else {
                isEditable = false
                canReverse = false
            }

            let displayObject = PanelDisplayObject(question: selectedQuestion, sequence: self.viewModel.questionsSequence, isEditable: isEditable, canReverse: canReverse)
            self.managementPanelView.setDisplayObject(displayObject: displayObject)

            self.managementPanelView.isHidden = false

        case .rearrange:
            break
        case .preview:
            self.previewLabel.text = self.viewModel.narrative
            self.previewView.isHidden = false
        }
    }

}

// MARK: - Actions
extension SequenceBuilderViewController {

    @objc private func segmentChanged(_ segmentedController: UISegmentedControl) {
        self.view.endEditing(true)
        self.viewModel.setMode(with: segmentedController.selectedSegmentIndex)
        self.tableView.reloadData()
        updateRightPanel()
        updateNavigationBar()
    }

    @objc private func endEditing() {
        self.view.endEditing(true)
    }

    @objc private func searchPressend() {
        let closure: ((SearchQuestionTableViewModel.SearchItem) -> Void) = { [weak self] searchItem in
            if let editedQuestion = self?.managementPanelView.editedQuestion {
                self?.viewModel.updateEditedQuestion(editedQuestion)
            }
            self?.viewModel.selectQuestion(searchItem.question)
            self?.viewModel.expand(path: searchItem.path)
            self?.tableView.reloadData()
            self?.scrollToQestion(searchItem.question)
        }

        self.onSearch?(self.viewModel.questionsSequence, closure)
    }

    @objc private func onGlobalSettingsClicked() {
        self.onGlobalSettings?()
    }

    @objc private func onBack() {
        if let editedQuestion = self.managementPanelView.editedQuestion {
            self.viewModel.updateEditedQuestion(editedQuestion)
        }

        self.viewModel.save()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func clearAllAnswers() {
        self.viewModel.clearAllAnswers()
    }

    @objc private func collapseAllQuestions() {
        self.viewModel.collapseAllQuestions()

        self.updateNavigationBar()
    }

    @objc private func expandAllQuestions() {
        self.viewModel.expandAllQuestions()

        self.updateNavigationBar()
    }

    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if self.viewModel.mode == .rearrange {
            self.handleDragAndDrop(gestureRecognizer)
        } else {
            switch gestureRecognizer.state {
            case .began:
                let location = gestureRecognizer.location(in: self.tableView)
                self.presentContextMenu(for: location)
            default:
                break
            }
        }
    }

    @objc private func addNewRootQestion() {
        self.showAlertWithPredifinedKinds(isChild: false, question: nil)
    }

    @objc private func copyButtonPressed() {
        UIPasteboard.general.string = self.previewLabel.text
    }
}

// MARK: - Drag and Drop
extension SequenceBuilderViewController {

    private func handleDragAndDrop(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.tableView)
        switch gestureRecognizer.state {
        case .began:
            onBeganDragging(location: location)
        case .changed:
            onChangedDragging(location: location, gestureRecognizer: gestureRecognizer)
        case .ended:
            onEndDragging(location: location, gestureRecognizer: gestureRecognizer)
        default:
            break
        }
    }

    private func onBeganDragging(location: CGPoint) {
        if let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = self.cellForPoint(location),
            let draggableQuestionId = cell.questionId,
            let draggableQuestion = self.viewModel.getQuestion(with: draggableQuestionId),
            self.viewModel.canEdit(question: draggableQuestion) {

            if self.viewModel.isExpanded(at: indexPath) {
                self.viewModel.expandCollapse(at: indexPath)
            }

            self.dragableView.isExpanded = cell.isExpanded
            self.dragableView.question = draggableQuestion
            self.dragableView.offsetLevel = cell.offsetLevel

            self.dragableViewTopConstraint?.constant = convertOutsideTableView(y: cell.frame.origin.y)
            self.dragableView.isHidden = false
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    private func setupTimerForHoverIfNeeded(location: CGPoint, gestureRecognizer: UILongPressGestureRecognizer) {
        if let initialLocation = self.initialHoverLocation {
            let distance = sqrt(pow(location.x-initialLocation.x, 2)+pow(location.y-initialLocation.y, 2))
            if distance < 10 {
                return
            }
        }

        self.initialHoverLocation = location
        self.hoverTimer?.invalidate()
        self.hoverTimer = nil
        self.hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { [weak self] (_) in
            guard let indexPath = self?.tableView.indexPathForRow(at: location),
                let sself = self,
                let question = self?.dragableView.question,
                let expandableQuestion = self?.viewModel.getQuestion(at: indexPath),
                question.id != expandableQuestion.id else { return }

            sself.initialHoverLocation = nil

            if !sself.viewModel.isExpanded(at: indexPath) {
                sself.viewModel.expandCollapse(at: indexPath)
            }

            if let question = self?.viewModel.getQuestion(at: indexPath),
                question.children.isEmpty,
                sself.viewModel.canAddChildren(to: question),
                sself.viewModel.canEdit(question: question) {
                sself.hoverView.isHidden = false
                sself.updateSeparatorPosition(for: location, gestureRecognizer: gestureRecognizer)
            }
        })
    }

    private func onChangedDragging(location: CGPoint, gestureRecognizer: UILongPressGestureRecognizer) {
        guard let draggableQuestion = self.dragableView.question,
            self.viewModel.canEdit(question: draggableQuestion) else {
                return
        }

        setupTimerForHoverIfNeeded(location: location, gestureRecognizer: gestureRecognizer)
        if let cell = self.cellForPoint(location) {
            let newHoverConstraint = convertOutsideTableView(y: cell.frame.origin.y)
            if (self.hoverViewTopConstraint?.constant ?? 0) != newHoverConstraint {
                self.hoverView.isHidden = true
            }

            self.hoverViewHeightConstraint?.constant = cell.frame.height - 1.5
            self.hoverViewTopConstraint?.constant = newHoverConstraint

            updateSeparatorPosition(for: location, gestureRecognizer: gestureRecognizer)
        }
        self.dragableViewTopConstraint?.constant = convertOutsideTableView(y: location.y)
    }

    private func onEndDragging(location: CGPoint, gestureRecognizer: UILongPressGestureRecognizer) {
        guard let draggableQuestion = self.dragableView.question,
            self.viewModel.canEdit(question: draggableQuestion) else {
                return
        }

        if self.hoverView.isHidden {
            if let cell = self.cellForPoint(location),
                let draggableQuestion = self.dragableView.question,
                let cellQuestionId = cell.questionId,
                let cellQuestion = self.viewModel.getQuestion(with: cellQuestionId),
                self.viewModel.canAddSibling(to: cellQuestion),
                self.viewModel.canEdit(question: draggableQuestion) {
                let locationInCell = gestureRecognizer.location(in: cell)
                if cell.frame.height / 2 > locationInCell.y {
                    self.viewModel.moveQuestion(draggableQuestion, at: .before(cellQuestion))
                } else {
                    self.viewModel.moveQuestion(draggableQuestion, at: .after(cellQuestion))
                }
            }
        } else {
            let hoverPosition: CGFloat = convertInsideTableView(y: self.hoverViewTopConstraint?.constant ?? 0)
            let hoverPoint = CGPoint(x: location.x, y: hoverPosition + 10)

            if let newIndexPath = self.tableView.indexPathForRow(at: hoverPoint),
                let draggableQuestion = self.dragableView.question,
                self.viewModel.canEdit(question: draggableQuestion),
                let newParent = self.viewModel.getQuestion(at: newIndexPath),
                self.viewModel.canAddChildren(to: newParent) {
                self.viewModel.changeParent(for: draggableQuestion, newParentAt: newIndexPath)
            }
        }

        self.separatorView.isHidden = true
        self.hoverView.isHidden = true
        self.dragableView.isHidden = true
        self.hoverTimer?.invalidate()
        self.hoverTimer = nil
        self.initialHoverLocation = nil
        self.dragableView.question = nil
    }

    private func updateSeparatorPosition(for location: CGPoint, gestureRecognizer: UILongPressGestureRecognizer) {
        if let cell = self.cellForPoint(location),
            let questionId = cell.questionId,
            let question = self.viewModel.getQuestion(with: questionId),
            let draggableQuestion = self.dragableView.question,
            self.viewModel.canEdit(question: draggableQuestion) {
            let locationInCell = gestureRecognizer.location(in: cell)

            let additionalOffsetLevel: Int
            let topPadding: CGFloat

            if self.hoverView.isHidden {
                additionalOffsetLevel = 1
                if cell.frame.height / 2 > locationInCell.y {
                    topPadding = convertOutsideTableView(y: cell.frame.origin.y)
                } else {
                    topPadding = convertOutsideTableView(y: cell.frame.origin.y) + cell.frame.height
                }
                self.separatorView.isHidden = !self.viewModel.canAddSibling(to: question)
            } else {
                topPadding = (self.hoverViewTopConstraint?.constant ?? convertOutsideTableView(y: cell.frame.origin.y)) + cell.frame.height
                additionalOffsetLevel = 2
                self.separatorView.isHidden = false
            }

            self.separatorViewTopConstraint?.constant = topPadding
            self.separatorViewLeadingConstraint?.constant = self.tableView.frame.minX + CGFloat((cell.offsetLevel + additionalOffsetLevel) * 20) + 104
        }
    }

    private func convertInsideTableView(y: CGFloat) -> CGFloat {
        return y - self.tableView.frame.origin.y + self.tableView.contentOffset.y
    }

    private func convertOutsideTableView(y: CGFloat) -> CGFloat {
        return y + self.tableView.frame.origin.y - self.tableView.contentOffset.y
    }

}

// MARK: - Context menu
extension SequenceBuilderViewController {

    private func presentContextMenu(for location: CGPoint) {
        guard let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = self.cellForPoint(location),
            let question = self.viewModel.getQuestion(at: indexPath) else { return }

        let alertController = self.contextMenuAlertController(for: question, sourceView: cell)

        self.presentAlert(alertController: alertController, sourceView: cell)
    }

    private func contextMenuAlertController(for question: Question, sourceView: UIView) -> UIAlertController {
        let alertController = UIAlertController(title: question.question, message: nil, preferredStyle: .actionSheet)

        if self.viewModel.mode == .preview {
            let singleClearAction = UIAlertAction(title: "Clear answers in this question", style: .default) { [weak self] (_) in
                self?.viewModel.clearAnswers(for: question)
            }
            alertController.addAction(singleClearAction)

            let branchClearAction = UIAlertAction(title: "Clear answers in this branch", style: .default) { [weak self] (_) in
                self?.viewModel.clearAnswersInBranch(for: question)
            }
            alertController.addAction(branchClearAction)
        }

        if self.viewModel.mode == .edit {
            if self.viewModel.canAddChildren(to: question) {
                let addNewChildAction = UIAlertAction(title: "Add new question as a child", style: .default) { [weak self] (_) in
                    self?.addNewChildQuestion(to: question)
                }
                alertController.addAction(addNewChildAction)
            }
            if self.viewModel.canAddSibling(to: question) {
                let addNewSiblingAction = UIAlertAction(title: "Add new sibling question", style: .default) { [weak self] (_) in
                    self?.addNewSiblingQuestion(to: question)
                }
                alertController.addAction(addNewSiblingAction)
            }
        }

        let expandAction = UIAlertAction(title: "Expand questions in branch", style: .default) { [weak self] (_) in
            self?.expandQuestions(in: question)
        }
        let collapseAction = UIAlertAction(title: "Collapse questions in branch", style: .default) { [weak self] (_) in
            self?.collapseQuestions(in: question)
        }

        if !question.children.isEmpty {
            alertController.addAction(expandAction)
            alertController.addAction(collapseAction)
        }
        if self.viewModel.mode == .edit {
            let copyExistingQuestions = UIAlertAction(title: "Copy existing questions", style: .default) { [weak self] (_) in
                self?.showCopyAsPicker(for: question, sourceView: sourceView)
            }
            alertController.addAction(copyExistingQuestions)
        }

        return alertController
    }

    private func showCopyAsPicker(for question: Question, sourceView: UIView) {
        var items: [SequenceBuilderViewModel.InsertOption] = []
        if self.viewModel.canAddSibling(to: question) {
            items.append(.toSibling)
        }
        if self.viewModel.canAddChildren(to: question) {
            items.append(.toChild)
        }

        let alertController = UIAlertController(title: "Copy as", message: nil, preferredStyle: .actionSheet)
        items.forEach { option in
            let action = UIAlertAction(title: option.rawValue, style: .default) { [weak self ]_ in
                self?.onSelectQuestions? { (_, _, selectedQuestions) in
                    guard let sself = self else { return }

                    if let editedQuestion = sself.managementPanelView.editedQuestion {
                        sself.viewModel.updateEditedQuestion(editedQuestion)
                    }

                    self?.viewModel.insert(toQuestion: question, insertOption: option, selectedQuestions: selectedQuestions)

                    if let editedQuestion = sself.managementPanelView.editedQuestion,
                        let questionToSelect = sself.viewModel.getQuestion(with: editedQuestion.id) {
                        sself.viewModel.selectQuestion(questionToSelect)
                    }

                    if !sself.viewModel.isExpanded(question) && option == .toChild {
                        sself.viewModel.expandCollapse(question)
                    }
                }
            }
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        self.presentAlert(alertController: alertController, sourceView: sourceView)
    }

    private func addNewChildQuestion(to question: Question) {
        self.showAlertWithPredifinedKinds(isChild: true, question: question)
    }

    private func addNewSiblingQuestion(to question: Question) {
        self.showAlertWithPredifinedKinds(isChild: false, question: question)
    }

    private func expandQuestions(in question: Question) {
        self.viewModel.expandAllQuestions(in: question)

        self.updateNavigationBar()
    }

    private func collapseQuestions(in question: Question) {
        self.viewModel.collapseAllQuestions(in: question)

        self.updateNavigationBar()
    }

    private func showAlertWithPredifinedKinds(isChild: Bool, question: Question?) {
        let alertController = UIAlertController(title: "Select question kind", message: nil, preferredStyle: .alert)

        for kind in self.viewModel.suppportedQuestionsToCreate {
            let action = UIAlertAction(title: kind.title, style: .default) { [weak self] _ in
                self?.changeKind(to: kind, isChild: isChild, question: question)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)

        self.presentAlert(alertController: alertController, sourceView: self.view)
    }

    private func changeKind(to kind: Question.Kind, isChild: Bool, question: Question?) {
        func addNewQuestion(kind: Question.Kind) {
            if let question = question {
                if isChild {
                    // Workaround for adding new question properly
                    if let editedQuestion = self.managementPanelView.editedQuestion {
                        self.viewModel.updateEditedQuestion(editedQuestion)
                    }

                    let newQuestion = self.viewModel.addNewChildQuestion(to: question, kind: kind)
                    self.viewModel.selectQuestion(newQuestion)

                    if !self.viewModel.isExpanded(question) {
                        self.viewModel.expandCollapse(question)
                    }

                    self.scrollToQestion(newQuestion)
                } else {
                    if let newQuestion = self.viewModel.addNewSiblingQuestion(to: question, kind: kind) {
                        if let editedQuestion = self.managementPanelView.editedQuestion {
                            self.viewModel.updateEditedQuestion(editedQuestion)
                        }
                        self.viewModel.selectQuestion(newQuestion)
                        self.scrollToQestion(newQuestion)
                    }
                }
            } else {
                let newQuestion = self.viewModel.addNewRootQuestion(kind: kind)
                self.viewModel.selectQuestion(newQuestion)
                self.scrollToQestion(newQuestion)
            }
        }

        switch kind {
        case .dateTime, .grouped, .size, .list, .variablesToOutput:
            addNewQuestion(kind: kind)
        case .reusable:
            self.onSelect?(.shared, { (url, _) in
                let filename = url.lastPathComponent.removingPercentEncoding?.replacingOccurrences(of: ".json", with: "") ?? ""
                let kind = Question.Kind.reusable(filename: filename)
                addNewQuestion(kind: kind)
            })
        case .image(_, let multiselection):
            let folder = Folder.images
            let fileManager = FileManager.default
            if let path = Bundle.main.path(forResource: folder.path, ofType: nil),
                let docsArray = try? fileManager.contentsOfDirectory(atPath: path) {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                docsArray.forEach { file in
                    let action = UIAlertAction(title: file, style: .default) { _ in
                        let kind = Question.Kind.image(imagePath: file, multiselection: multiselection)
                        addNewQuestion(kind: kind)
                    }
                    alertController.addAction(action)
                }
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
                self.presentAlert(alertController: alertController, sourceView: self.view)
            }
        }
    }

    private func scrollToQestion(_ question: Question) {
        guard let indexPath = self.viewModel.getIndexPath(for: question) else {
            return
        }

        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SequenceBuilderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfQuestions()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionTableViewCell.className) as? QuestionTableViewCell, let question = self.viewModel.getQuestion(at: indexPath) else {
            return UITableViewCell()
        }

        update(cell: cell, with: question, at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard self.viewModel.mode == .edit,
            let question = self.viewModel.getQuestion(at: indexPath) else {
                return false
        }

        return self.viewModel.canEdit(question: question)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let editingQuestion = self.managementPanelView.editedQuestion {
                self.viewModel.updateEditedQuestion(editingQuestion)
            }
            self.viewModel.deleteQuestion(at: indexPath)
            if self.viewModel.selectedQuestion == nil && self.viewModel.getNumberOfQuestions() > 0 {
                let newIndexPath: IndexPath
                if indexPath.row > 0 {
                    newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                } else {
                    newIndexPath = indexPath
                }
                let newSelectedQuestion = self.viewModel.getQuestion(at: newIndexPath)
                self.viewModel.selectQuestion(newSelectedQuestion)
            } else {
                updateRightPanel()
            }
        default:
            break
        }
    }
}

// MARK: - Update QuestionTableViewCell
private extension SequenceBuilderViewController {

    private func update(cell: QuestionTableViewCell, with question: Question, at indexPath: IndexPath) {
        cell.offsetLevel = self.viewModel.getOffsetLevel(at: indexPath)
        cell.isExpanded = self.viewModel.isExpanded(at: indexPath)

        switch self.viewModel.mode {
        case .edit:
            updateForEditMode(cell: cell, with: question, at: indexPath)
        case .rearrange:
            updateForRearrangeMode(cell: cell, with: question, at: indexPath)
        case .preview:
            updateForPreviewMode(cell: cell, with: question, at: indexPath)
        }

        cell.onLoad = { [weak self] question in
            self?.viewModel.replaceWithReusableQuestion(questionToReplace: question)
            if let loadedQuestion = self?.viewModel.getQuestion(at: indexPath) {
                self?.viewModel.selectQuestion(loadedQuestion)
            }
        }
        cell.onExpand = { [weak self] in
            self?.viewModel.expandCollapse(at: indexPath)
            self?.updateNavigationBar()
        }

        cell.setQuestion(question)
    }

    private func updateForEditMode(cell: QuestionTableViewCell, with question: Question, at indexPath: IndexPath) {
        cell.selectedOptions = []
        cell.isCellSelected = self.viewModel.selectedQuestion?.id == question.id
        cell.canSelectOptions = false

        cell.onTap = { [weak self] in
            if let editedQuestion = self?.managementPanelView.editedQuestion {
                self?.viewModel.updateEditedQuestion(editedQuestion)
            }
            self?.viewModel.selectQuestion(question)
            self?.tableView.reloadData()
        }
        cell.onSelectedOptions = nil
    }

    private func updateForRearrangeMode(cell: QuestionTableViewCell, with question: Question, at indexPath: IndexPath) {
        cell.selectedOptions = []
        cell.isCellSelected = false
        cell.canSelectOptions = false

        cell.onTap = nil
        cell.onSelectedOptions = nil
    }

    private func updateForPreviewMode(cell: QuestionTableViewCell, with question: Question, at indexPath: IndexPath) {
        cell.selectedOptions = self.viewModel.getSelectedOptions(for: question)
        cell.isCellSelected = false
        cell.canSelectOptions = true

        cell.onTap = nil
        cell.onSelectedOptions = { [weak self] options in
            self?.viewModel.updateAnswer(for: question, options: options)
        }
    }
}
