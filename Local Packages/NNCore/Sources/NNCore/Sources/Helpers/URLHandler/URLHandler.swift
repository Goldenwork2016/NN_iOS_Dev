//
//  URLHandler.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Slavik Voloshyn. All rights reserved.
//

import UIKit

public protocol URLHandler {
    func open(_ url: URL)
}

extension UIApplication: URLHandler {

    public func open(_ url: URL) {
        self.open(url, options: [:], completionHandler: nil)
    }
}
