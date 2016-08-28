//
//  Color.swift
//  Color utilities
//  Loop Trips Sample
//

import Foundation
import UIKit

class Colors {
    static let backgroundColor = UIColor(netHex: 0x465666)
    static let tealColor = UIColor(netHex: 0x43A89E)
    static let transparentGrayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    static let mapLineColor = Colors.transparentGrayColor
    
    static let trackingEnabled = UIColor(red: 72, green: 167, blue: 158, alpha: 0.8)
    static let trackingDisabled = UIColor(red: 153, green: 83, blue: 119, alpha: 0.8)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
