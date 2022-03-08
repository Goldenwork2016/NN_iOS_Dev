//
//  FeedbackViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 08.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import UIKit

final class FeedbackViewModel {

    let feedbackSender: FeedbackSender
    let guideString: String = """
Need us to update a question or add questions for a new area of care? This is your direct line to the folks that can make it happen.

We want to know what you think about Narrative Nurse and how we can improve it to be more useful to you.

Tap the “Start Feedback” button to start an email and remember to not include private patient information in any correspondence to us.

Thank you for using Narrative Nurse!
"""

    init(feedbackSender: FeedbackSender) {
        self.feedbackSender = feedbackSender
    }
}
