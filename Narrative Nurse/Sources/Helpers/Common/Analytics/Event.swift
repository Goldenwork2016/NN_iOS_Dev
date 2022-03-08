//
//  Event.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 27.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import NNCore

enum Event {

    case jobSelect(job: JobTitle)

    case sequenceSelect(facility: Facility, job: JobTitle)
    case sequenceStart
    case sequenceDone
    case sequenceCancel
    case sequenceOtherOption
    case sequenceAnsweredQuestion(duration: TimeInterval)

    case share(source: String)

    case autospeechStart
    case autospeechPause
    case autospeechFinish
    case autospeechContinue
}

extension Event: AnalyticsEvent {

    var name: String {
        switch self {
        case .jobSelect:
            return "Select Job"
        case .sequenceSelect:
            return "Select Sequence"
        case .sequenceStart:
            return "Start Sequence"
        case .sequenceCancel:
            return "Cancel Sequence"
        case .sequenceDone:
            return "Done Sequence"
        case .share:
            return "Share"
        case .autospeechStart:
            return "Auto Speach Start"
        case .autospeechPause:
            return "Auto Speach Pause"
        case .autospeechFinish:
            return "Auto Speach Finish"
        case .autospeechContinue:
            return "Auto Speach Contrinue"
        case .sequenceOtherOption:
            return "Other Option Selected"
        case .sequenceAnsweredQuestion:
            return "Answered Question"
        }
    }

    var metadada: [String: String]? {
        switch self {
        case .jobSelect(let job):
            return ["title": job.rawValue]
        case .sequenceSelect(let categoryItem, let job):
            return ["title": categoryItem.title,
                    "job": job.rawValue]
        case .share(let source):
            return ["source": source]
        case .sequenceAnsweredQuestion(let duration):
            return ["duration": "\(duration)"]
        default:
            return nil
        }
    }

}
