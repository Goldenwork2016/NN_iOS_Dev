//
//  PolygonView.swift
//  Narrative Nurse
//
//  Created by Danylo Manko on 10.03.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import UIKit
import NNCore

final class PolygonView: UIView {

    let addTransparanceToThePath: Bool
    private let pathes: [UIBezierPath]

    private var selectedPathes: [UIBezierPath] = []

    var onPath: ((Int) -> Void)?

    init(allPoints: [[CGPoint]], addTransparanceToThePath: Bool = true) {
        var pathes: [UIBezierPath] = []
        for points in allPoints {
            if let path = UIBezierPath.makePath(for: points) {
                pathes.append(path)
            }
        }

        self.pathes = pathes
        self.addTransparanceToThePath = addTransparanceToThePath

        super.init(frame: .zero)

        self.backgroundColor = .clear

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        self.pathes.forEach { (path) in
            let fillColor = self.selectedPathes.contains(path) ? UIColor.nn_orange.withAlphaComponent(self.addTransparanceToThePath ? 0.38 : 1) : UIColor.clear
            fillColor.setFill()

            path.fill()
        }
    }

    func setSelectedPathes(indices: [Int]) {
        var selectedPathes: [UIBezierPath] = []
        indices.forEach { (index) in
            guard let path = self.pathes[safe: index] else { return }
            selectedPathes.append(path)
        }

        self.selectedPathes = selectedPathes
        self.setNeedsDisplay()
    }

    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)

        for index in self.pathes.indices {
            if self.pathes[index].contains(tapLocation) {
                self.onPath?(index)
                return
            }
        }
    }
}
