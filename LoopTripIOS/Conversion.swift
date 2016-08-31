//
//  Conversion.swift
//  Conversion utilities
//  Loop Trips Sample
//

import Foundation
import UIKit

class ConversionUtils {
    class func kilometersToMiles(kilometers:Double) -> Double {
        let miles: Double = kilometers / 1.60934
        return miles.roundToPlaces(2)
    }
}

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
