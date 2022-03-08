//
//  QuestionTableViewCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 25.06.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionTableViewCell: UITableViewCell {
    
    private let scrollView = UIScrollView()
    private let expandButton = UIButton()
    private let label = UILabel()
    private let prefixLabel = UILabel()
    private let stackView = UIStackView()
    private let optionsStackView = UIStackView()
    private let accessoriesStackView = UIStackView()
    
    private var question: Question?
    var questionId: Identifier? {
        return self.question?.id
    }
    
    var offsetLevel: Int {
        set {
            self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: CGFloat(30 + newValue * 20), bottom: 0, right: 0)
        }
        get {
            return Int((self.stackView.layoutMargins.left - 30) / 20)
        }
    }
    
    var isExpanded: Bool {
        set {
            if newValue {
                self.expandButton.setTitle("-", for: .normal)
            } else {
                self.expandButton.setTitle("+", for: .normal)
            }
        }
        get {
            return self.expandButton.titleLabel?.text == "-"
        }
    }
    
    var isCellSelected: Bool {
        set {
            if newValue {
                self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            } else {
                self.backgroundColor = .white
            }
        }
        get {
            return self.backgroundColor != .white
        }
    }
    
    var canSelectOptions: Bool {
        set {
            self.optionsStackView.isUserInteractionEnabled = newValue
        }
        get {
            return self.optionsStackView.isUserInteractionEnabled
        }
    }
    
    private var prefix: String? {
        if let narrative = self.question?.narrative {
            var prefix: String = ""
            if narrative.before != nil && narrative.before?.isEmpty != true {
                prefix += "B"
            }
            if narrative.after != nil && narrative.after?.isEmpty != true {
                prefix += "A"
            }
            if narrative.afterChildren != nil && narrative.afterChildren?.isEmpty != true {
                prefix += "C"
            }
            return prefix
        }
        return nil
    }
    
    private var options: [Option] {
        return self.question?.options ?? []
    }
    var selectedOptions: [Option] = []
    
    var onExpand: VoidClosure?
    var onTap: VoidClosure?
    var onLoad: ((Question) -> Void)?
    var onSelectedOptions: (([Option]) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    func setQuestion(_ question: Question) {
        self.question = question

        self.updateViews()
    }
    
    static func removeCache() {
        cachedGroupQuestionConverter.removeAll()
        cashedSizeOptions.removeAll()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.question = nil
        self.prefixLabel.text = nil
        self.removeOptions()
    }
    
    private func setupViews() {
        self.selectionStyle = .none
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.expandButton.addTarget(self, action: #selector(self.didPressExpandButton), for: .touchUpInside)
        self.expandButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        self.expandButton.setTitle("-", for: .normal)
        self.expandButton.setTitleColor(.black, for: .normal)
        
        self.label.numberOfLines = 1
        
        self.prefixLabel.textColor = .systemGray
        self.prefixLabel.font = .preferredFont(forTextStyle: .caption1)
        self.prefixLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.optionsStackView.axis = .horizontal
        self.optionsStackView.spacing = 10
        
        self.accessoriesStackView.axis = .horizontal
        self.accessoriesStackView.spacing = 10
        
        self.stackView.addArrangedSubview(self.expandButton)
        self.stackView.addArrangedSubview(self.prefixLabel)
        self.stackView.addArrangedSubview(self.label)
        self.stackView.addArrangedSubview(self.scrollView)
        self.stackView.axis = .horizontal
        self.stackView.spacing = 10
        self.stackView.isLayoutMarginsRelativeArrangement = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didDoubleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.stackView.addGestureRecognizer(tapGestureRecognizer)
        
        self.contentView.nn_addSubview(self.stackView)
        
        let optionsContainerStackView = UIStackView(arrangedSubviews: [self.optionsStackView, self.accessoriesStackView])
        optionsContainerStackView.spacing = 10
        
        self.scrollView.nn_addSubview(optionsContainerStackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.heightAnchor.constraint(equalTo: container.heightAnchor)
            ]
        }
    }
    
    private func updateViews() {
        self.label.text = self.question?.question
        self.prefixLabel.text = self.prefix
        
        if let question = self.question, question.children.isEmpty {
            self.expandButton.setTitle(" ", for: .normal)
        }
        
        if let question = self.question, self.selectedOptions.isEmpty {
            cachedGroupQuestionConverter[question.id] = GroupQuestionConverter(question: question)
        }
        
        self.removeOptions()
        self.addOptions()
        self.addAccessories()
        
        self.optionsStackView.addArrangedSubview(UIView())
    }
    
    private func addAccessories() {
        guard let question = self.question else {
            return
        }
        
        switch question.kind {
        case .variablesToOutput(_), .size, .grouped, .list(_):
            break
        case .reusable(let filename):
            self.label.text = "Reusable: [\(filename)]"
            let loadReusableQuestionButton = UIButton()
            loadReusableQuestionButton.setTitle("Tap to Load", for: .normal)
            loadReusableQuestionButton.setTitleColor(.nn_blue, for: .normal)
            loadReusableQuestionButton.addTarget(self, action: #selector(self.loadReusableQuestion), for: .touchUpInside)
            self.accessoriesStackView.addArrangedSubview(loadReusableQuestionButton)
        case .image(_, _):
            let selectNewAreaButton = UIButton()
            selectNewAreaButton.setTitle("Select", for: .normal)
            selectNewAreaButton.setTitleColor(.nn_blue, for: .normal)
            selectNewAreaButton.addTarget(self, action: #selector(self.selectNewImageOption), for: .touchUpInside)
            selectNewAreaButton.isUserInteractionEnabled = self.canSelectOptions
            self.accessoriesStackView.addArrangedSubview(selectNewAreaButton)
        case .dateTime(_):
            let selectNewAreaButton = UIButton()
            selectNewAreaButton.setTitle("Select", for: .normal)
            selectNewAreaButton.setTitleColor(.nn_blue, for: .normal)
            selectNewAreaButton.addTarget(self, action: #selector(self.selectDateTimeOption), for: .touchUpInside)
            selectNewAreaButton.isUserInteractionEnabled = self.canSelectOptions
            self.accessoriesStackView.addArrangedSubview(selectNewAreaButton)
        }
    }
    
    private func addOptions() {
        for index in self.options.indices {
            let option = self.options[index]
            if let question = self.question {
                switch question.kind {
                case .list, .reusable(_), .variablesToOutput(_):
                    addTextOptionView(option: option)
                case .grouped:
                    addGroupOptionView(option: option, question: question)
                case .dateTime:
                    if self.selectedOptions.contains(option) {
                        addTextOptionView(option: option)
                    }
                case .size:
                    addSizeOptionView(option: option)
                case .image(_ , _):
                    if self.selectedOptions.contains(option) {
                        addTextOptionView(option: option)
                    }
                }
            }
        }
    }
    
    private func removeOptions() {
        self.optionsStackView.subviews.forEach { $0.removeFromSuperview() }
        self.accessoriesStackView.subviews.forEach { $0.removeFromSuperview() }
    }
}


//MARK: - Actions
extension QuestionTableViewCell {
    
    @objc private func didPressExpandButton() {
        self.onExpand?()
    }
    
    @objc private func didDoubleTap() {
        self.onTap?()
    }
    
    @objc private func loadReusableQuestion() {
        guard let question = self.question else { return }
        self.onLoad?(question)
    }
}

//MARK: - Select Date/Time Options
extension QuestionTableViewCell {
    
    @objc private func selectDateTimeOption() {
        guard let question = self.question else {
            return
        }
        
        let vc = OrigianQuestionCellWrapperViewController.instantiate(with: question, onOptions: { [weak self] options in
            self?.selectedOptions = options
            self?.onSelectedOptions?(options)
            self?.updateViews()
        })
        UIApplication.present(vc)
    }

}

//MARK: - Image Options
extension QuestionTableViewCell {
    
    @objc private func selectNewImageOption() {
        guard let question = self.question else {
            return
        }
        
        let vc = OrigianQuestionCellWrapperViewController.instantiate(with: question, onOptions: { [weak self] options in
            self?.selectedOptions = options
            self?.onSelectedOptions?(options)
            self?.updateViews()
        })
        UIApplication.present(vc)
    }
}

//MARK: - Group Options
private var cachedGroupQuestionConverter: [Identifier: GroupQuestionConverter] = [:]
extension QuestionTableViewCell {
    func addGroupOptionView(option: Option, question: Question) {
        for child in option.kind.children {
              let selectorView = SelectorOptionView()
              selectorView.isSelected = cachedGroupQuestionConverter[question.id]?.getSelectedOption(for: child) != nil
              selectorView.title = child.kind.title
              selectorView.selectedValue = cachedGroupQuestionConverter[question.id]?.getSelectedOption(for: child)?.kind.title ?? "--"
              switch child.kind {
              case .groupedOverride(_, let children):
                  selectorView.items = children.compactMap { $0.kind.title }
                  selectorView.onChanged = { [weak self] selectedTitle in
                      if let selectedTitle = selectedTitle {
                          guard let selectedOption = children.first(where: { $0.kind.title == selectedTitle }) else {
                              return
                          }
                          
                          self?.didSelectGroupOption(parentOption: child, childOption: selectedOption)
                      } else {
                          self?.didDeselectGroupOption(parentOption: child)
                      }
                  }
              default:
                  if let rootOption = question.options.first(where: { $0.kind.children.contains(child) }),
                      case Option.Kind.grouped(_, _, _, _, let options) = rootOption.kind {
                      selectorView.items = options.compactMap { $0.kind.title }
                      
                      selectorView.onChanged = { [weak self] selectedTitle in
                          if let selectedTitle = selectedTitle {
                              guard let selectedOption = options.first(where: { $0.kind.title == selectedTitle }) else {
                                  return
                              }
                              
                              self?.didSelectGroupOption(parentOption: child, childOption: selectedOption)
                          } else {
                              self?.didDeselectGroupOption(parentOption: child)
                          }
                      }
                  }
              }
              
              self.optionsStackView.addArrangedSubview(selectorView)
          }
          
          let view = UIView()
          view.backgroundColor = .black
          view.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
          self.optionsStackView.addArrangedSubview(view)
    }
    
    private func didDeselectGroupOption(parentOption: Option) {
        guard let question = self.question else {
            return
        }
        
        let groupQuestionConverter = cachedGroupQuestionConverter[question.id] ?? GroupQuestionConverter(question: question)
        groupQuestionConverter.removeSelectedOption(for: parentOption)
        
        self.selectedOptions.removeAll()
        if let generatedOption = groupQuestionConverter.nextButtonPressed() {
            self.selectedOptions.append(generatedOption)
        }
        
        cachedGroupQuestionConverter[question.id] = groupQuestionConverter
        
        self.onSelectedOptions?(self.selectedOptions)
        updateViews()
    }
    
    private func didSelectGroupOption(parentOption: Option, childOption: Option) {
        guard let question = self.question else {
            return
        }
        
        let groupQuestionConverter = cachedGroupQuestionConverter[question.id] ?? GroupQuestionConverter(question: question)
        groupQuestionConverter.optionSelected(parentOption: parentOption, childOption: childOption)
        self.selectedOptions.removeAll()
        if let generatedOption = groupQuestionConverter.nextButtonPressed() {
            self.selectedOptions.append(generatedOption)
        }
        
        cachedGroupQuestionConverter[question.id] = groupQuestionConverter
        
        self.onSelectedOptions?(self.selectedOptions)
        updateViews()
    }
}

//MARK: - Text Options
extension QuestionTableViewCell {
    
    private func addTextOptionView(option: Option) {
        let optionView = TextOptionView()
        optionView.isSelected = self.selectedOptions.contains(option)
        if let title = option.kind.title, !title.isEmpty {
            optionView.title = title
        } else {
            optionView.title = "No title"
        }
        optionView.onTap = { [weak self] in
            self?.didTapTextOption(on: option)
        }
        self.optionsStackView.addArrangedSubview(optionView)
    }
    
    private func didTapTextOption(on option: Option) {
        guard let question = self.question else { return }
        
        switch question.kind.isMultiselection {
        case true:
            if option.kind.isNone {
                self.selectedOptions = [option]
            } else {
                self.selectedOptions.removeAll(where: { $0.kind.isNone })
                if self.selectedOptions.contains(option) {
                    self.selectedOptions.removeAll(where: { $0.id == option.id })
                } else {
                    self.selectedOptions.append(option)
                }
            }
        case false:
            if self.selectedOptions.contains(option) {
                self.selectedOptions = []
            } else {
                self.selectedOptions = [option]
            }
        }
        
        self.onSelectedOptions?(self.selectedOptions)
        updateViews()
    }
}

//MARK: - Size Options
private var cashedSizeOptions: [Identifier: String] = [:]
extension QuestionTableViewCell {
    
    private func addSizeOptionView(option: Option) {
        let value = cashedSizeOptions[option.id]
        
        let optionView = TextFieldOptionView()
        optionView.isSelected = self.selectedOptions.contains(option)
        optionView.title = option.kind.title
        optionView.value = value
        optionView.onChanged = { [weak self] newValue in
            self?.didChangeSizeValue(newValue: newValue, option: option)
        }
        optionView.onTap = { [weak self] in
            self?.didTapSizeOptions()
        }
        self.optionsStackView.addArrangedSubview(optionView)
    }
    
    private func didTapSizeOptions() {
        let optionsToSelect: [Option] = self.options.compactMap { item in
            if let selectedValue = cashedSizeOptions[item.id] {
                return createEditedSizeOption(value: selectedValue, from: item)
            }
            
            return nil
        }
        
        if optionsToSelect.count == self.options.count && self.selectedOptions.isEmpty {
            self.selectedOptions = optionsToSelect
        } else {
            self.selectedOptions.removeAll()
        }
        
        self.selectedOptions.sort { (self.options.firstIndex(of: $0) ?? 0) < (self.options.firstIndex(of: $1) ?? 0) }
        
        self.onSelectedOptions?(self.selectedOptions)
        updateViews()
    }
    
    private func didChangeSizeValue(newValue: String?, option: Option) {
        if let newValue = newValue, !newValue.replacingOccurrences(of: " ", with: "").isEmpty {
            cashedSizeOptions[option.id] = newValue
        } else {
            cashedSizeOptions.removeValue(forKey: option.id)
        }
        
        let optionsToSelect: [Option] = self.options.compactMap { item in
            if let selectedValue = cashedSizeOptions[item.id] {
                return createEditedSizeOption(value: selectedValue, from: item)
            }
            
            return nil
        }
        
        if optionsToSelect.count == self.options.count {
            self.selectedOptions = optionsToSelect
        } else {
            self.selectedOptions.removeAll()
        }
        
        self.selectedOptions.sort { (self.options.firstIndex(of: $0) ?? 0) < (self.options.firstIndex(of: $1) ?? 0) }
        
        self.onSelectedOptions?(self.selectedOptions)
        updateViews()
    }
    
    private func createEditedSizeOption(value: String, from option: Option) -> Option {
        let narrative = getEditedNarrativeSizeOption(for: option, with: value)
        return Option(kind: option.kind, narrative: narrative, id: option.id)
    }
    
    private func getEditedNarrativeSizeOption(for option: Option, with value: String) -> String {
        let allOptions = self.question?.options ?? []
        let units = Set<String>(allOptions.compactMap(\.kind.unit))
        let unit = option.kind.unit ?? String()
        let addUnitToTheLast = units.count <= 1
        
        var components: [String] = []
        components.append(value)
        
        if !addUnitToTheLast {
            components.append(unit)
        }
        
        components.append(option.narrative)
        
        if option == allOptions.last, addUnitToTheLast {
            components.append(unit)
        }
        
        return components.filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
