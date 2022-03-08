//
//  UIAlertController+TextFields.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 17.07.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit

public extension UIAlertController {

    static func textFieldAlert(title: String? = nil, message: String? = nil, placeholderText: String? = nil, okayButtonText: String = "Okay", completion: @escaping ((String?) -> Void)) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = placeholderText
        }

        let saveAction = UIAlertAction(title: okayButtonText, style: .default) { (_) in
            if let textField = alertController.textFields?.first, let text = textField.text, !text.isEmpty {
                completion(text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completion(nil) })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        return alertController
    }

}
