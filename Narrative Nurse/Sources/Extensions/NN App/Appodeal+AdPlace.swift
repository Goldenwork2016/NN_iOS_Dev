//
//  Appodeal+Ad.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 23.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import Appodeal

extension Appodeal {

    static func showAd(place: AdPlace, in viewController: UIViewController) {
        showAd(place.kind, forPlacement: place.placement, rootViewController: viewController)
    }

    static func isReadyToShow(place: AdPlace) -> Bool {
        return isReadyForShow(with: place.kind)
    }
}

private extension AdPlace {

    var kind: AppodealShowStyle {
        switch self {
        case .sequence:
            return .bannerBottom
        case .beforeResult:
            return .interstitial
        case .result1:
            return .bannerBottom
        case .result2:
            return .bannerBottom
        }
    }

}
