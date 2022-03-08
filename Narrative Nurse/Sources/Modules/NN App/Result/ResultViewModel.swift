//
//  ResultViewModel.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 28.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import AVFoundation
import NNCore

final class ResultViewModel {
    
    let sentence: NoteHistory
    var replacements: [GlobalSettingItem] = []
    let isOld: Bool
    
    private let synthesizer = AVSpeechSynthesizer()
    private let pronunciations: [GlobalSettingItem] = GlobalSettingKind.pronunciation.load()

    private(set) var totalUtterances: Int = 0
    private(set) var currentUtterance: Int = 0
    private(set) var totalTextLength: Int = 0
    private(set) var spokenTextLengths: Int = 0

    init(answers: [Answer], questions: [Question], categoryItem: Facility, clientIdentifier: ClientIdentifier, noteHistoryProvider: NoteHistoryProvider) {
        self.isOld = false
        self.replacements = []
        
        let narrativeGenerator = NarrativeGenerator()
        let narrative = narrativeGenerator.getNarrative(questions: questions, answers: answers)
        self.sentence = NoteHistory(value: narrative, createdAt: Date(), facility: categoryItem, clientIdentifier: clientIdentifier, jobTitle: Preference.jobTitle, isActive: true)
        
        noteHistoryProvider.save(note: self.sentence)
    }

    init(sentence: NoteHistory) {
        self.sentence = sentence
        self.isOld = true
        self.replacements = []
    }

    func createPDF() -> URL? {
        let pdfCreator = NarrativePDFCreator(narrative: sentence.value)

        let fileURL =  FileManager.default.temporaryDirectory
            .appendingPathComponent(self.sentence.facility.title)
            .appendingPathExtension("pdf")

        do {
            try pdfCreator.create().write(to: fileURL)
        } catch {
            return nil
        }

        return fileURL
    }
}

// MARK: - Ad

extension ResultViewModel {

    func getAdIndexes() -> [Int] {
        let resultString = self.sentence.value
        let sentences = resultString.sentences

        var indexes: [Int] = []

        if sentences.count >= 5 {
            let middle = Int(ceil(Float(sentences.count) / 2.0))
            let firstIndex = sentences[0...middle-1].joined(separator: String.sentenceSepatator).count + 1

            indexes.append(firstIndex)
        }

        indexes.append(resultString.count + indexes.count)

        return indexes
    }

}

private extension NSAttributedString {
    func components(separatedBy separator: String) -> [NSAttributedString] {
        var result = [NSAttributedString]()
        let separatedStrings = string.components(separatedBy: separator)
        var range = NSRange(location: 0, length: 0)
        for string in separatedStrings {
            range.length = string.utf16.count
            let attributedString = attributedSubstring(from: range)
            result.append(attributedString)
            range.location += range.length + separator.utf16.count
        }
        return result
    }
}

// MARK: - Autospeach
extension ResultViewModel {

    func startAutospeach(string attributedString: NSAttributedString) {
        if self.synthesizer.isSpeaking && !self.synthesizer.isPaused {
            stopAutospeach()
        } else if self.synthesizer.isSpeaking && self.synthesizer.isPaused {
            self.synthesizer.continueSpeaking()
        } else {
            stopAutospeach()
            
            try? AVAudioSession.sharedInstance().setCategory(.playback,mode: .default)
            
            let sentences = attributedString.components(separatedBy: .sentenceSepatator)
            totalUtterances = sentences.count
            currentUtterance = 0
            totalTextLength = 0
            spokenTextLengths = 0
            for string in sentences {
                let mutableAttributedString = NSMutableAttributedString(attributedString: string)
                let pronunciationKey = NSAttributedString.Key(rawValue: AVSpeechSynthesisIPANotationAttribute)

                for item in self.pronunciations {
                    let range = NSString(string: string.string).range(of: item.key)
                    mutableAttributedString.addAttributes([pronunciationKey: item.value], range: range)
                }
                for item in self.pronunciations {
                    let range = NSString(string: string.string).range(of: item.key.capitalizingFirstLetter())
                    mutableAttributedString.addAttributes([pronunciationKey: item.value], range: range)
                }

                let utterance = AVSpeechUtterance(attributedString: mutableAttributedString)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = Preference.getUtiranceSettingValue(.rate)
                utterance.pitchMultiplier = Preference.getUtiranceSettingValue(.pitch)
                utterance.volume = 1.0
                utterance.postUtteranceDelay = TimeInterval(Preference.getUtiranceSettingValue(.sentenceDelay))

                self.totalTextLength = self.totalTextLength + string.length

                self.synthesizer.speak(utterance)
            }
        }
    }

    func stopAutospeach() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }

    func setAutospeachDelegate(_ delegate: AVSpeechSynthesizerDelegate) {
        self.synthesizer.delegate = delegate
    }
}
