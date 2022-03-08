//
//  SequencesListViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 16.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class SequencesListViewController: UIViewController {

    let viewModel: SequencesListViewModel

    var onSequence: ((URL, SequenceFileType) -> Void)?
    var onAdd: VoidClosure?
    var onGlobalSettings: VoidClosure?

    private let tableView = UITableView()

    init(viewModel: SequencesListViewModel) {
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
        self.viewModel.update()
        self.tableView.reloadData()
    }

    private func setupView() {
        self.title = "Sequence Builder"

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(SequenceCell.self, forCellReuseIdentifier: SequenceCell.className)

        self.view.nn_addSubview(self.tableView)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Global Settings", style: .plain, target: self, action: #selector(onGlobalSettingsClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddClicked))
    }
}

// MARK: - Actions
extension SequencesListViewController {

    @objc private func onGlobalSettingsClicked() {
        self.onGlobalSettings?()
    }

    @objc private func onAddClicked() {
        self.onAdd?()
    }

    private func deteteSequence(at indexPath: IndexPath) {
        let countItems = self.viewModel.getItems(in: indexPath.section).count
        let title = self.viewModel.getTitle(at: indexPath)

        let alert = UIAlertController(title: nil, message: "Do you want to delete \(title)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            if self.viewModel.delete(at: indexPath) {
                if countItems == 1 {
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SequencesListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getCountSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getItems(in: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SequenceCell.className, for: indexPath) as? SequenceCell else {
            return UITableViewCell()
        }

        let title = self.viewModel.getTitle(at: indexPath)
        let details = self.viewModel.getDetails(at: indexPath)
        let showManageButtons = self.viewModel.infoReprestentation == .all

        cell.update(title: title, subtitle: details, showManageButton: showManageButtons)
        cell.onShare = { [weak self] in
            guard let fileURL = self?.viewModel.getUrl(at: indexPath) else { return }

            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = cell
            self?.present(activityViewController, animated: true, completion: nil)
        }
        cell.onDelete = { [weak self] in
            self?.deteteSequence(at: indexPath)
        }
        cell.onCopyPath = { [weak self] in
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = self?.viewModel.getUrl(at: indexPath)?.absoluteString
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.getSectionTitle(at: section)
    }
}

// MARK: - UITableViewDelegate
extension SequencesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = self.viewModel.getUrl(at: indexPath),
            let fileType = self.viewModel.getFileType(at: indexPath) {
            self.onSequence?(url, fileType)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

private final class SequenceCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let shareButton = NNButton()
    private let deleteButton = NNButton()
    private let copyPathButton = NNButton()

    var onShare: VoidClosure?
    var onDelete: VoidClosure?
    var onCopyPath: VoidClosure?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.contentView.preservesSuperviewLayoutMargins = false

        self.titleLabel.font = .preferredFont(forTextStyle: .headline)
        self.titleLabel.textColor = .black

        self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        self.subtitleLabel.textColor = .gray

        self.shareButton.setTitle("Share", for: .normal)
        self.shareButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: 0).isActive = false
        self.shareButton.addTarget(self, action: #selector(onShareClicked), for: .touchUpInside)
        self.shareButton.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)
        
        self.deleteButton.setTitle("Delete", for: .normal)
        self.deleteButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.deleteButton.heightAnchor.constraint(equalToConstant: 0).isActive = false
        self.deleteButton.addTarget(self, action: #selector(onDeleteClicked), for: .touchUpInside)
        self.deleteButton.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)
        
        self.copyPathButton.setTitle("Copy Path", for: .normal)
        self.copyPathButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.copyPathButton.heightAnchor.constraint(equalToConstant: 0).isActive = false
        self.copyPathButton.addTarget(self, action: #selector(onCopyPathClicked), for: .touchUpInside)
        self.copyPathButton.titleLabel?.font = .nn_font(type: .bold, sizeFont: 24)

        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .fill

        let rootStackView = UIStackView(arrangedSubviews: [stackView, self.shareButton, self.deleteButton, self.copyPathButton])
        rootStackView.spacing = 8
        rootStackView.axis = .horizontal
        rootStackView.distribution = .fill
        rootStackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        rootStackView.isLayoutMarginsRelativeArrangement = true

        self.contentView.nn_addSubview(rootStackView)
    }

    @objc private func onShareClicked() {
        self.onShare?()
    }

    @objc private func onDeleteClicked() {
        self.onDelete?()
    }

    @objc private func onCopyPathClicked() {
        self.onCopyPath?()
    }

    func update(title: String, subtitle: String?, showManageButton: Bool) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.shareButton.isHidden = !showManageButton
        self.deleteButton.isHidden = !showManageButton
        self.copyPathButton.isHidden = !showManageButton
    }

}
