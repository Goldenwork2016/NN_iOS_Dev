//
//  JobTypeViewModel.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

final class SplashViewModel {
    
    var introAnimationUrl: URL? {
        let file = File.introAnimation

        guard let videoString = Bundle.main.path(forResource: file.path, ofType: file.type) else {
            return nil
        }

        return URL(fileURLWithPath: videoString)
    }

}
