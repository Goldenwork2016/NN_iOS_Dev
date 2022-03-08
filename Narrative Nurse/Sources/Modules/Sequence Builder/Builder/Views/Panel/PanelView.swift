//
//  PanelView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 05.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore
class PanelView: UIView {

    private(set) var displayObject: PanelDisplayObject?

    var question: Question? {
        return self.displayObject?.question
    }
    var sequence: QuestionsSequence? {
        return self.displayObject?.sequence
    }

    var onPresent: ((UIAlertController) -> Void)?
    var onPresentFileSelector: ((SequenceFileType, @escaping URLClosure) -> Void)?
    var onUpdated: VoidClosure?

    var title: String {
        assertionFailure("Needs to override")
        return ""
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisplayObject(displayObject: PanelDisplayObject) {
        self.displayObject = displayObject

        self.updateViews()
    }

    func setupViews() {

    }

    func updateViews() {

    }
}
