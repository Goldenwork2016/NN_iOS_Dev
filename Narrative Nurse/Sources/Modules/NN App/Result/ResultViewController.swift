//
//  ResultViewController.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 28.02.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import AVFoundation
import Appodeal
import SubviewAttachingTextView
import NNCore

final class ResultViewController: UIViewController {

    private let textView = SubviewAttachingTextView()
    private let shareButton = UIButton()
    private let printButton = UIButton()
    private let playButton = UIButton()
    private let menuView = NNDropdownMenuView()

    let viewModel: ResultViewModel

    var nativeAdQueue: APDNativeAdQueue!
    var nativeArray: [APDNativeAd] = []
    var onUtiranceSettings: VoidClosure?
    var onFeedback: VoidClosure?

    private lazy var text: NSAttributedString = {
        let text = self.viewModel.sentence.value

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 1

        let params = [NSAttributedString.Key.font: UIFont.nn_font(type: .regular, sizeFont: 21),
                      NSAttributedString.Key.foregroundColor: UIColor.black,
                      NSAttributedString.Key.kern: -0.14,
                      NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key: Any]
        var attibutedString = NSAttributedString(string: text, attributes: params)
        //attibutedString = setupAd(in: attibutedString)

        return attibutedString
    }()

    init(viewModel: ResultViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.setAutospeachDelegate(self)
        self.setupViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewModel.stopAutospeach()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
    }

    private func setupViews() {
        self.view.backgroundColor = UIColor.nn_lightGray

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backButtonPressed))

        let menuItemContainerView = MenuItemContainerView()
        menuItemContainerView.addItem(with: "Make a suggestion about this question", closure: { [weak self] in
            self?.onFeedback?()
            self?.menuView.switchState()
        })
        menuItemContainerView.addItem(with: "Speech settings", closure: { [weak self] in
            self?.onUtiranceSettings?()
            self?.viewModel.stopAutospeach()
            self?.menuView.switchState()
        })
        self.menuView.itemsContainerView = menuItemContainerView
        self.navigationItem.titleView = self.menuView

        let titleLabel = UILabel()
        titleLabel.text = "Narrative Note"
        titleLabel.font = .nn_font(type: .boldOblique, sizeFont: 30)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.heightAnchor.constraint(equalToConstant: 71).isActive = true
        let titleGradientView = titleLabel.nn_wrappedWithGradientView()

        let logoImageView = UIImageView()
        logoImageView.image = #imageLiteral(resourceName: "logoOneRow")
        logoImageView.contentMode = .center
        logoImageView.heightAnchor.constraint(equalToConstant: 88).isActive = true

        self.textView.textContainerInset = UIEdgeInsets(top: 0, left: 28, bottom: 20, right: 28)
        self.textView.isEditable = false
        self.textView.attributedText = self.text
        self.textView.backgroundColor = .nn_lightGray

        let buttonsStackView = UIStackView(arrangedSubviews: [self.shareButton, self.printButton, self.playButton])
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.axis = .horizontal
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 90, bottom: 11, right: 90)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        buttonsStackView.clipsToBounds = false
        buttonsStackView.backgroundColor = .nn_lightGray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            buttonsStackView.layer.nn_applyShadow(color: .black, alpha: 0.3, x: 0, y: 3, blur: 29, spread: -9)
        }

        self.shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        self.shareButton.addTarget(self, action: #selector(self.shareButtonPressed), for: .touchUpInside)
        self.shareButton.widthAnchor.constraint(equalToConstant: 51).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: 51).isActive = true

        self.printButton.setImage(#imageLiteral(resourceName: "print"), for: .normal)
        self.printButton.addTarget(self, action: #selector(self.printButtonPressed), for: .touchUpInside)
        self.printButton.widthAnchor.constraint(equalToConstant: 51).isActive = true
        self.printButton.heightAnchor.constraint(equalToConstant: 51).isActive = true

        self.playButton.setImage(#imageLiteral(resourceName: "sound"), for: .normal)
        self.playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        self.playButton.tintColor = .nn_lightBlue
        self.playButton.widthAnchor.constraint(equalToConstant: 51).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 51).isActive = true

        let finishButton = NNButton()
        finishButton.setTitle("Finish", for: .normal)
        finishButton.isHidden = self.viewModel.isOld
        finishButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        let clientIdentifierView = ClientIdentifierView()
        clientIdentifierView.update(with: self.viewModel.sentence.clientIdentifier)
        clientIdentifierView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        let footerView = FooterView()
        footerView.showShadow = true
        footerView.trailingView = finishButton
        footerView.centerView = clientIdentifierView
        
        let stackView = UIStackView(arrangedSubviews: [menuItemContainerView, titleGradientView, logoImageView, self.textView, buttonsStackView, footerView])
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.setCustomSpacing(12, after: titleGradientView)
        stackView.setCustomSpacing(-19, after: buttonsStackView)

        self.view.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
        }
    }
}

// MARK: - Ads
extension ResultViewController {

    private func setupAd(in attributedString: NSAttributedString) -> NSAttributedString {
        var text = attributedString
        let indexes = self.viewModel.getAdIndexes()

        for (i, index)  in indexes.enumerated() {
            let place: AdPlace = i == 0 ? .result1 : .result2
            let bannerView = createBannerView(place: place)
            let bannerViewAttachement = SubviewTextAttachment(view: bannerView)
            text = text.insertingAttachment(bannerViewAttachement, at: index)
        }

        return text
    }

    private func createBannerView(place: AdPlace) -> UIView {
        let size = kAPDAdSize320x50

        let bannerView = AppodealBannerView(size: size, rootViewController: self)
        bannerView.usesSmartSizing = true
        bannerView.placement = place.placement
        bannerView.adSize = size
        bannerView.loadAd()

        return bannerView
    }

}

// MARK: - Actions
extension ResultViewController {

    @objc private func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func close() {
        if !self.viewModel.isOld {
            Analytics.shared.logEvent(Event.sequenceDone)
        }

        self.dismiss(animated: true, completion: nil)
    }

    @objc private func shareButtonPressed() {
        share(item: self.viewModel.sentence.value)
    }

    @objc private func printButtonPressed() {
        guard let fileURL = self.viewModel.createPDF() else {
            return
        }

        share(item: fileURL)
    }

    private func share(item: Any) {
        let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.assignToContact]
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { (activity, success, _, _) in
            guard let activity = activity, success else {
                return
            }

            Analytics.shared.logEvent(Event.share(source: activity.rawValue))
        }

        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc private func playButtonPressed() {
        self.playButton.tintColor = .nn_lightBlue
        self.viewModel.startAutospeach(string: self.text)
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension ResultViewController: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableText = NSMutableAttributedString(attributedString: self.text)
        let rangeOfUterance = mutableText.mutableString.range(of: utterance.attributedSpeechString.string)
        let newCharacterRange = NSRange(location: rangeOfUterance.location + characterRange.location, length: characterRange.length)

        self.textView.attributedText = attributedString(from: mutableText, highlighting: newCharacterRange)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.textView.attributedText = self.text
        self.playButton.tintColor = .nn_orange
        Analytics.shared.logEvent(Event.autospeechStart)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.textView.attributedText = self.text
        self.playButton.tintColor = .nn_lightBlue
        Analytics.shared.logEvent(Event.autospeechFinish)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.playButton.tintColor = .nn_lightBlue
        Analytics.shared.logEvent(Event.autospeechPause)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        self.playButton.tintColor = .nn_orange
        Analytics.shared.logEvent(Event.autospeechContinue)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.textView.attributedText = self.text
    }

    private func attributedString(from string: NSAttributedString, highlighting characterRange: NSRange) -> NSAttributedString {
        guard characterRange.location != NSNotFound else {
            return self.text
        }

        let mutableAttributedString = NSMutableAttributedString(attributedString: string)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.nn_orange, range: characterRange)
        return mutableAttributedString
    }
}
