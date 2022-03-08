//
//  AnswersView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class AnswersView: PanelView {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let addNewButton = UIButton()
    
    override var title: String {
        return "Answers"
    }
    
    private(set) var options: [Option] = []
    private var addNewButtonWidthConstraint: NSLayoutConstraint?
    
    override func setupViews() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.isEditing = false
        self.tableView.backgroundColor = .white
        
        self.tableView.register(AnswerImageOptionTableViewCell.self, forCellReuseIdentifier: AnswerImageOptionTableViewCell.className)
        self.tableView.register(AnswerSizeOptionTableViewCell.self, forCellReuseIdentifier: AnswerSizeOptionTableViewCell.className)
        self.tableView.register(AnswerTimeOptionTableViewCell.self, forCellReuseIdentifier: AnswerTimeOptionTableViewCell.className)
        self.tableView.register(AnswerListOptionTableViewCell.self, forCellReuseIdentifier: AnswerListOptionTableViewCell.className)
        self.tableView.register(GroupedAnswerTableViewCell.self, forCellReuseIdentifier: GroupedAnswerTableViewCell.className)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.addNewButton.setImage(UIImage(systemName: "plus"), for: .normal)
        self.addNewButton.tintColor = .black
        self.addNewButton.addTarget(self, action: #selector(self.addNewOption), for: .touchUpInside)
        self.addNewButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.addNewButtonWidthConstraint = self.addNewButton.widthAnchor.constraint(equalToConstant: 44)
        self.addNewButtonWidthConstraint?.isActive = true
        self.addNewButton.contentMode = .scaleAspectFit
        self.addNewButton.contentHorizontalAlignment = .left
        
        self.nn_addSubview(self.tableView)
    }
    
    override func setDisplayObject(displayObject: PanelDisplayObject) {
        super.setDisplayObject(displayObject: displayObject)
        
        self.options = self.question?.options ?? []
        self.tableView.reloadData()
    }
    
    override func updateViews() {
        self.tableView.reloadData()
        
        guard let question = self.question else { return }
        
        switch question.kind {
        case .size, .list(_), .image(_, _):
            self.addNewButton.setTitle(nil, for: .normal)
            self.addNewButton.setImage(UIImage(systemName: "plus"), for: .normal)
            self.addNewButtonWidthConstraint?.constant = 44
        case .grouped:
            self.addNewButton.setImage(nil, for: .normal)
            self.addNewButton.setTitle("Add Group", for: .normal)
            self.addNewButton.setTitleColor(.black, for: .normal)
            self.addNewButtonWidthConstraint?.constant = 100
        case .variablesToOutput(_), .reusable(_), .dateTime(_):
            break
        }
        
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    private func cellReuseIdentifier() -> String? {
        guard let question = self.question else { return nil }
        
        switch question.kind {
        case .image:
            return AnswerImageOptionTableViewCell.className
        case .size:
            return AnswerSizeOptionTableViewCell.className
        case .dateTime:
            return AnswerTimeOptionTableViewCell.className
        case .list:
            return AnswerListOptionTableViewCell.className
        case .grouped:
            return GroupedAnswerTableViewCell.className
        default:
            return nil
        }
    }
    
    private func getNumberOfRows() -> Int {
        guard let question = self.question else { return 0 }
        
        switch question.kind {
        case .dateTime:
            return 1
        default:
            return self.options.count
        }
    }
    
    @objc private func toggleEdit() {
        if case .grouped = self.question?.kind {
            rearangeGroupQuestion()
        } else {
            self.tableView.isEditing.toggle()
            
            self.tableView.reloadData()
        }
    }
    
    @objc private func addNewOption() {
        func addOption(_ option: Option) {
            self.options.append(option)
            self.tableView.reloadData()
            self.onUpdated?()
        }
        
        guard let question = self.question else { return }
        
        switch question.kind {
        case .list:
            let option = Option(kind: .text(title: ""), narrative: "", id: UUID().uuidString)
            addOption(option)
        case .grouped:
            let option = Option(kind: .grouped(title: "", beforeGroup: .init(singular: nil, plural: nil), afterGroup: .init(singular: nil, plural: nil), children: [], options: []), narrative: "", id: UUID().uuidString)
            addOption(option)
        case .image:
            let option = Option(kind: .polygon(polygon: [], title: ""), narrative: "", id: UUID().uuidString)
            addOption(option)
        case .size:
            let option = Option(kind: .size(title: "", unit: ""), narrative: "", id: UUID().uuidString)
            addOption(option)
        default:
            break
        }
    }
    
    private func moveOption(from startIndexPath: IndexPath, to endIndexPath: IndexPath) {
        guard let option = self.options[safe: startIndexPath.row],
            let startIndex = self.options.firstIndex(of: option) else { return }
        
        self.options.remove(at: startIndex)
        self.options.insert(option, at: endIndexPath.row)
        
        self.tableView.reloadData()
        
        self.onUpdated?()
    }
    
    private func removeOption(at indexPath: IndexPath) {
        self.options.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .right)
        
        self.onUpdated?()
    }
    
    private func replace(option: Option, editedOption: Option) {
        guard let index = self.options.firstIndex(of: option) else { return }
        
        self.options.remove(at: index)
        self.options.insert(editedOption, at: index)
        
        self.onUpdated?()
    }
}

//MARK: - UITableViewDataSource
extension AnswersView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellReuseIdentifier = self.cellReuseIdentifier(),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? AnswerOptionCell else { return UITableViewCell() }
        
        let option = self.options[safe: indexPath.row]
        if let option = option {
            cell.setOption(option)
        }
        cell.onEdit = { [weak self, weak cell] in
            guard let editedOption = cell?.editedOption, let option = option else { return }
            self?.replace(option: option, editedOption: editedOption)
        }
        
        if let cell = cell as? GroupedAnswerTableViewCell {
            cell.title = "Group \(indexPath.row + 1)"
            cell.onReload = { [weak self] in
                self?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.removeOption(at: indexPath)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.moveOption(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

//MARK: - UITableViewDelegate
extension AnswersView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.question?.kind {
        case .size, .list(_), .image(_, _), .grouped:
            let title = self.tableView.isEditing ? "Done" : "Rearrange"
            let button = UIButton()
            button.setTitleColor(.nn_lightBlue, for: .normal)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(self.toggleEdit), for: .touchUpInside)
            
            let headerView = UIView()
            headerView.backgroundColor = .white
            
            let stackView = UIStackView(arrangedSubviews: [UIView(), button])
            stackView.axis = .horizontal
            
            headerView.nn_addSubview(stackView)
            
            return headerView
        case .variablesToOutput(_), .reusable(_), .dateTime(_), .none:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch self.question?.kind {
        case .size, .list(_), .image(_, _), .grouped:
            let footerView = UIView()
            
            let stackView = UIStackView(arrangedSubviews: [self.addNewButton, UIView()])
            stackView.axis = .horizontal
            
            footerView.nn_addSubview(stackView)
            
            return footerView
        case .variablesToOutput(_), .reusable(_), .dateTime(_), .none:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }
    
}


//MARK: - Rearange group questions
extension AnswersView {
    
    private func rearangeGroupQuestion() {
        var elements = ["Groups"]
        for i in self.options.enumerated() {
            elements.append("[Group - \(i.offset + 1)] General questions")
            elements.append("[Group - \(i.offset + 1)] General answers")
            //elements.append("[Group - \(i.offset + 1)] Override questions")
        }
        
        NNDropDown.show(anchor: self.tableView, items: elements) { [weak self] (_, selectedValue) in
            guard let sself = self,
                let selectedIndex = elements.firstIndex(of: selectedValue) else {
                    return
            }
            
            if selectedIndex == 0 {
                sself.rearangeGroups()
            } else {
                let groupIndex = (selectedIndex - 1) / 2
                let groupOption = sself.options[groupIndex]
                let optionInGroup = (selectedIndex - 1) % 2
                
                switch optionInGroup {
                case 0:
                    sself.rearangeGeneralQuestions(in: groupOption)
                case 1:
                    sself.rearangeGeneralAnswers(in: groupOption)
                case 2:
                    sself.rearangeOverrideQuestions(in: groupOption)
                default:
                    assertionFailure()
                }
            }
        }
    }
    
    private func rearangeGeneralAnswers(in groupOption: Option) {
        guard case Option.Kind.grouped(let title, let beforeGroup, let afterGroup, let children, var options) = groupOption.kind else {
            return
        }
        
        let titles = options.compactMap { $0.kind.title ?? "" }
        let sortOptionsViewController = SortOptionsViewController(titles: titles)
        let sortOptionsNavigationController = UINavigationController(rootViewController: sortOptionsViewController)
        sortOptionsViewController.onMove = {  (startIndexPath, endIndexPath) in
            guard let startOption = options[safe: startIndexPath.row],
                let startIndex = options.firstIndex(of: startOption) else { return }
            
            options.remove(at: startIndex)
            options.insert(startOption, at: endIndexPath.row)
            
            let editedGroupOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: children, options: options), narrative: groupOption.narrative, id: groupOption.id)
            
            self.replace(option: groupOption, editedOption: editedGroupOption)
            self.updateViews()
        }
        
        UIApplication.present(sortOptionsNavigationController)
    }
    
    private func rearangeGeneralQuestions(in groupOption: Option) {
        guard case Option.Kind.grouped(let title, let beforeGroup, let afterGroup, let children, let options) = groupOption.kind else {
            return
        }
        
        var generalQuestions = children.filter { !$0.kind.isParent }
        let titles = generalQuestions.compactMap { $0.kind.title ?? "" }
        let sortOptionsViewController = SortOptionsViewController(titles: titles)
        let sortOptionsNavigationController = UINavigationController(rootViewController: sortOptionsViewController)
        sortOptionsViewController.onMove = {  (startIndexPath, endIndexPath) in
            guard let startOption = generalQuestions[safe: startIndexPath.row],
                let startIndex = generalQuestions.firstIndex(of: startOption) else { return }
            
            generalQuestions.remove(at: startIndex)
            generalQuestions.insert(startOption, at: endIndexPath.row)
            generalQuestions += children.filter { $0.kind.isParent }
            
            let editedGroupOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: generalQuestions, options: options), narrative: groupOption.narrative, id: groupOption.id)
            
            self.replace(option: groupOption, editedOption: editedGroupOption)
            self.updateViews()
        }
        
        UIApplication.present(sortOptionsNavigationController)
    }
    
    private func rearangeOverrideQuestions(in groupOption: Option) {
        guard case Option.Kind.grouped(let title, let beforeGroup, let afterGroup, let children, let options) = groupOption.kind else {
            return
        }
        
        var ocerrideQuestions = children.filter({ $0.kind.isParent })
        let titles = ocerrideQuestions.compactMap { $0.kind.title ?? "" }
        let sortOptionsViewController = SortOptionsViewController(titles: titles)
        let sortOptionsNavigationController = UINavigationController(rootViewController: sortOptionsViewController)
        sortOptionsViewController.onMove = {  (startIndexPath, endIndexPath) in
            guard let startOption = ocerrideQuestions[safe: startIndexPath.row],
                let startIndex = ocerrideQuestions.firstIndex(of: startOption) else { return }
            
            ocerrideQuestions.remove(at: startIndex)
            ocerrideQuestions.insert(startOption, at: endIndexPath.row)
            ocerrideQuestions += children.filter { !$0.kind.isParent }
            
            let editedGroupOption = Option(kind: .grouped(title: title, beforeGroup: beforeGroup, afterGroup: afterGroup, children: ocerrideQuestions, options: options), narrative: groupOption.narrative, id: groupOption.id)
            
            self.replace(option: groupOption, editedOption: editedGroupOption)
            self.updateViews()
        }
        
        UIApplication.present(sortOptionsNavigationController)
    }
    
    private func rearangeGroups() {
        var titles: [String] = []
        for i in self.options.enumerated() {
            titles.append("Group - \(i.offset + 1)")
        }
        let sortOptionsViewController = SortOptionsViewController(titles: titles)
        let sortOptionsNavigationController = UINavigationController(rootViewController: sortOptionsViewController)
        sortOptionsViewController.onMove = { [weak self] (startIndexPath, endIndexPath) in
            self?.moveOption(from: startIndexPath, to: endIndexPath)
        }
        UIApplication.present(sortOptionsNavigationController)
    }
    
}
