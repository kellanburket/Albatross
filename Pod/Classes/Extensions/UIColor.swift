//
//  UIColor.swift
//  Pods
//
//  Created by Kellan Cummings on 7/9/15.
//
//

import Foundation


internal extension UIColor {

    internal class func parse(hex: Int) -> UIColor? {
        return self.parse(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
    
    internal class func parse(#red: Int, green: Int, blue: Int, alpha: Int = 0) -> UIColor? {
        if red >= 0 && red < 256 && green >= 0 && green < 256 && blue >= 0 && blue < 256 && alpha >= 0 && alpha < 256 {
            return self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        } else {
            return nil
        }
    }
    
}