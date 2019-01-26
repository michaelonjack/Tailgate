//
//  SlantedView.swift
//  Tailgate
//
//  Created by Michael Onjack on 1/26/19.
//  Copyright © 2019 Michael Onjack. All rights reserved.
//

import UIKit

@IBDesignable
class SlantedView: UIView {
    
    @IBInspectable var slantHeight: CGFloat = 25 { didSet { updatePath() } }
    @IBInspectable var slantSide: Int = 0 { didSet { updatePath() } }
    
    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 0
        shapeLayer.fillColor = UIColor.white.cgColor    // with masks, the color of the shape layer doesn’t matter; it only uses the alpha channel; the color of the view is dictate by its background color
        return shapeLayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        switch slantSide {
        case 0:
            path.move(to: CGPoint(x: bounds.origin.x + slantHeight, y: bounds.origin.y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        case 1:
            path.move(to: bounds.origin)
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX - slantHeight, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        default:
            break
        }
        path.close()
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
    }
}
