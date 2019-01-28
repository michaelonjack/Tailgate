//
//  UIColor+Additions.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/1/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let lavender = UIColor(red:0.72, green:0.56, blue:0.90, alpha:1.0)
    static let steel = UIColor(red:0.475635, green:0.475647, blue:0.47564, alpha:1.0)
    static let salmon = UIColor(red: 1.0, green: 0.493272, blue: 0.473998, alpha: 1.0)
    static let cantaloupe = UIColor(red: 1.0, green: 0.832346, blue: 0.473206, alpha: 1.0)
    static let nickel = UIColor(red: 0.574149, green: 0.574162, blue: 0.574155, alpha: 1.0)
    
    var lighterColor: UIColor {
        return lighterColor(removeSaturation: 0.3, resultAlpha: -1)
    }
    
    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
}
