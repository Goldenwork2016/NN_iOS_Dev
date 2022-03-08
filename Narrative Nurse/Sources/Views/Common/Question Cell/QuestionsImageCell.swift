//
//  QuestionsImageCell.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 13.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionsImageCell: QuestionsBaseCell {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    private var selectedOptions: [Option] = [] {
        didSet {
            self.onReadyToGoNext?(!self.selectedOptions.isEmpty)
        }
    }
    private var imageViewHeightConstraint: NSLayoutConstraint?

    override func prepareForReuse() {
        super.prepareForReuse()

        self.selectedOptions.removeAll()
        self.imageView.subviews.forEach { $0.removeFromSuperview() }
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    override func setupViews() {
        super.setupViews()

        self.imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: 0)
        self.imageViewHeightConstraint?.isActive = true

        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logoTwoRowsDark"))
        logoImageView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        logoImageView.contentMode = .center

        let stackView = UIStackView(arrangedSubviews: [self.imageView, logoImageView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 20)

        self.scrollView.nn_addSubview(stackView) { (view, container) -> [NSLayoutConstraint] in
            [
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.widthAnchor.constraint(equalTo: container.widthAnchor)
            ]
        }

        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.bounces = false

        self.cardView.nn_addSubview(self.scrollView)
    }

    override func getSelectedOptions() -> [Option] {
        return self.selectedOptions
    }

    override func setQuestion(_ question: Question, isFirstQuestion: Bool) {
        super.setQuestion(question, isFirstQuestion: isFirstQuestion)

        guard case Question.Kind.image(let imagePath, let multiselection) = question.kind else { return }

        if let image = UIImage(named: File.image(imagePath).path) {
            let ratio = image.size.height / image.size.width
            let width = self.frame.width - 40
            let height = width * ratio
            let multiplier = width / image.size.width

            self.imageView.image = image
            self.imageView.isUserInteractionEnabled = true
            self.imageViewHeightConstraint?.constant = height

            var allPoints: [[CGPoint]] = []
            for index in 0...question.options.count - 1 {
                if let points = self.getPolygon(at: index, multiplier: multiplier) {
                    allPoints.append(points)
                }
            }

            let polygonView = PolygonView(allPoints: allPoints)
            polygonView.onPath = { [weak self, weak polygonView] index in
                guard let sself = self, let option = sself.question?.options[safe: index] else { return }
                if multiselection {
                    if let index = sself.selectedOptions.firstIndex(of: option) {
                        sself.selectedOptions.remove(at: index)
                    } else {
                        sself.selectedOptions.append(option)
                    }
                } else {
                    sself.selectedOptions = [option]
                }

                let selectedPathes = sself.selectedOptions.compactMap({ question.options.firstIndex(of: $0) })
                polygonView?.setSelectedPathes(indices: selectedPathes)
            }
            self.imageView.nn_addSubview(polygonView)

        }
    }

    private func getPolygon(at index: Int, multiplier: CGFloat) -> [CGPoint]? {
        let multiplier = Double(multiplier)
        if let option = self.question?.options[safe: index], case Option.Kind.polygon(let polygon, _) = option.kind {
            var index: Int = 0
            var points: [CGPoint] = []
            while index <= polygon.count - 1 {
                let point = CGPoint(x: polygon[index] * multiplier, y: polygon[index + 1] * multiplier)
                points.append(point)
                index += 2
            }
            return points
        }

        return nil
    }
}
