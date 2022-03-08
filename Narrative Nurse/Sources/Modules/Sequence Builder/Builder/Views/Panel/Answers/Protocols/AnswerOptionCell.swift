//
//  OptionSelectable.swift
//  Sequence Builder
//
//  Created by Voloshyn Slavik on 06.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore
import UIKit

protocol AnswerOptionCell: UITableViewCell {
    var editedOption: Option? { get }
    var onEdit: VoidClosure? { get set }
    func setOption(_ option: Option)
}
