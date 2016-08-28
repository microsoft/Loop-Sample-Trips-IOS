//
//  Conversion.swift
//  Conversion utilities
//  Loop Trips Sample
//

import Foundation
import UIKit

class Conversions {
    static func kilometersToMiles(speedInMPH:Double) ->Double {
        let speedInKPH: Double = speedInMPH / 1.60934
        return speedInKPH
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
