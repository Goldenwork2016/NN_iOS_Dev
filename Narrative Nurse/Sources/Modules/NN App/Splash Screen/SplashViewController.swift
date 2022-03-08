//
//  JobTypeViewController.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import AVFoundation
import NNCore

final class SplashViewController: BaseViewController {

    let viewModel: SplashViewModel

    var onAnimationFinished: VoidClosure?

    private let videoContainer = UIView()
    private var player: AVPlayer?

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.view.backgroundColor = .white
        let multiplayer = self.view.frame.height / 812.0

        let videoContainerMultiplayer: CGFloat = 1.3
        let videoContainerWidth = self.view.frame.width * videoContainerMultiplayer
        let videoContainerHeight = videoContainerWidth * 0.56
        self.view.nn_addSubview(self.videoContainer, layoutConstraints: { (view, container) in
            [
                view.widthAnchor.constraint(equalToConstant: videoContainerWidth),
                view.heightAnchor.constraint(equalToConstant: videoContainerHeight),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -40 * multiplayer),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ]
        })
        if let videoUrl = self.viewModel.introAnimationUrl {
            let playerItem = AVPlayerItem(url: videoUrl)
            NotificationCenter.default.addObserver(self, selector: #selector(self.onIntroAnimationFinished(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

            self.player = AVPlayer(playerItem: playerItem)
            let layer = AVPlayerLayer(player: player)
            layer.frame = CGRect(x: 0, y: 0, width: videoContainerWidth, height: videoContainerHeight)
            layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoContainer.layer.addSublayer(layer)
            self.player?.play()
        }
    }

    @objc private func onIntroAnimationFinished(sender: Notification) {
        self.onAnimationFinished?()
    }
}
