//
//  FeedbackSender.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 08.12.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import MapKit
import MessageUI
import NNCore

protocol FeedbackSenderDelegate: class {
    func didReceiveStatus(feedbackSender: FeedbackSender, status: FeedbackSender.Status)
}

final class FeedbackSender: NSObject {

    private static let recipient = "chrislee100@gmail.com"

    enum Status {
        case sent
        case cancelled
        case failed(Error)
    }

    weak var delegate: FeedbackSenderDelegate?

    func sendFeedback(from viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            let error = NNError(title: "Mail application is not found", description: "Please, install Mail application in order to send a feedback.")
            self.delegate?.didReceiveStatus(feedbackSender: self, status: .failed(error))
            return
        }

        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([FeedbackSender.recipient])
        viewController.present(mailVC, animated: true, completion: nil)
    }

}

extension FeedbackSender: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            guard let sself = self else { return }

            switch result {
            case .cancelled:
                sself.delegate?.didReceiveStatus(feedbackSender: sself, status: .cancelled)
            case .saved, .sent:
                sself.delegate?.didReceiveStatus(feedbackSender: sself, status: .sent)
            case .failed:
                sself.delegate?.didReceiveStatus(feedbackSender: sself, status: .failed(error ?? NNError(title: "Error", description: "Something went wrong. Please, try again.")))
            @unknown default:
                assert(false, "Need to handle new case")
                break
            }
        }
    }
}
