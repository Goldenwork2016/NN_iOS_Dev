//
//  QuestionImagePreview.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 11.08.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class QuestionImagePreview: UIView {

    let image: UIImage
    let options: [Option]
    private(set) var selectedOptions: [Option]
    let multiselection: Bool

    private let imageView = UIImageView()

    init(image: UIImage, options: [Option], frame: CGRect, selectedOptions: [Option], multiselection: Bool) {
        self.image = image
        self.options = options
        self.selectedOptions = selectedOptions
        self.multiselection = multiselection

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .white

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = self.image
        self.imageView.isUserInteractionEnabled = true

        let multiplierY = self.frame.height / image.size.height
        let multiplierX = self.frame.width / image.size.width

        var allPoints: [[CGPoint]] = []
        for index in 0...self.options.count - 1 {
            if let points = self.getPolygon(at: index, multiplierX: multiplierX, multiplierY: multiplierY) {
                allPoints.append(points)
            }
        }

        let polygonView = PolygonView(allPoints: allPoints)
        polygonView.onPath = { [weak self, weak polygonView] index in
            guard let sself = self,
                let option = sself.options[safe: index],
                let polygonView = polygonView else { return }

            if sself.multiselection {
                if sself.selectedOptions.contains(option) {
                    sself.selectedOptions.removeAll(where: { $0 == option })
                } else {
                    sself.selectedOptions.append(option)
                }
            } else {
                sself.selectedOptions = [option]
            }

            sself.drawSelectedRegions(polygonView: polygonView)
        }

        self.imageView.nn_addSubview(polygonView)
        self.nn_addSubview(self.imageView)

        drawSelectedRegions(polygonView: polygonView)
    }

    private func drawSelectedRegions(polygonView: PolygonView) {
        let selectedPathes = self.selectedOptions.compactMap { self.options.firstIndex(of: $0) }
        polygonView.setSelectedPathes(indices: selectedPathes)
    }

    private func getPolygon(at index: Int, multiplierX: CGFloat, multiplierY: CGFloat) -> [CGPoint]? {
        if let option = self.options[safe: index], case Option.Kind.polygon(let polygon, _) = option.kind, polygon.count > 1 {
            var index: Int = 0
            var points: [CGPoint] = []
            while index <= polygon.count - 1 {
                let point = CGPoint(x: polygon[index] * Double(multiplierX), y: polygon[index + 1] * Double(multiplierY))
                points.append(point)
                index += 2
            }
            return points
        }

        return nil
    }
}
