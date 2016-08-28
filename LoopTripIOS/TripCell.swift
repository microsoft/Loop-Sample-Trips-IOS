//
//  TripCell.swift
//  Loop-Trip
//

import Foundation
import UIKit
import LoopSDK

class TripCell: UITableViewCell {
        
    @IBOutlet weak var startLocation: UILabel!
    @IBOutlet weak var destinationArrow: UIImageView!
    @IBOutlet weak var endLocation: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationDuration: UILabel!
    @IBOutlet weak var sampleTripIndicator: UILabel!

    override func awakeFromNib () {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.init(red: 228, green: 228, blue: 228)
    }
    
    func initialize(trip: LoopTrip) {
        setLocaleLabel(trip)
        
        let distanceInMiles = Conversions.kilometersToMiles(trip.distanceTraveledInKilometers)
        self.locationDistance.text = "\(distanceInMiles.roundToPlaces(2)) mi."
        
        let duration: String = trip.endedAt.offsetFrom(trip.startedAt)
        self.locationDuration.text = duration
        
        let relativeDate: String = NSDate.timeAgoSinceDate(trip.startedAt, numericDates: false)
        self.locationTime.text = relativeDate
    }
    
    func setLocaleLabel(trip: LoopTrip) {
        let startLocaleText = trip.startLocale?.getFriendlyName().uppercaseString
        let endLocaleText = trip.endLocale?.getFriendlyName().uppercaseString
        
        if (startLocaleText != nil) {
            setStartLocaleLabelText(startLocaleText!)
            
            if (endLocaleText != nil && endLocaleText! != startLocaleText!) {
                // if they're the same we shouldn't display twice
                setEndLocaleLabelText(endLocaleText!)
                
            } else {
                clearEndLocaleLabelText()
            }
        } else {
            setStartLocaleLabelText("UNKONWN")
            clearEndLocaleLabelText()
        }
    }
    
    private func setStartLocaleLabelText(text: String) {
        self.startLocation.text = text
    }
    
    private func setEndLocaleLabelText(text: String) {
        self.endLocation.text = text
    }
    
    private func clearEndLocaleLabelText() {
        self.destinationArrow.removeFromSuperview()
        self.endLocation.removeFromSuperview()
    }
}

