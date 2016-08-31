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
    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationDuration: UILabel!
    @IBOutlet weak var sampleTripIndicator: UILabel!
    
    let knownLocationsModel = KnownLocationModel.sharedInstance
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.tableCellBackgroundColor
    }
    
    func initialize(trip: LoopTrip, sampleTrip: Bool) {
        if (!sampleTrip) {
            sampleTripIndicator.removeFromSuperview()
        }
        
        setLocaleLabel(trip)
        
        self.locationDistance.text = " \(ConversionUtils.kilometersToMiles(trip.distanceTraveledInKilometers)) mi. "
        self.locationDuration.text = trip.endedAt.offsetFrom(trip.startedAt)
        self.locationTime.text = trip.startedAt.relativeDayAndTime(trip.endedAt)
    }
    
    func setLocaleLabel(trip: LoopTrip) {
        let startLocaleText = trip.startLocale?.getFriendlyName().uppercaseString
        let endLocaleText = trip.endLocale?.getFriendlyName().uppercaseString
        var locationIconName = "ICO Cell Blank"
        
        if knownLocationsModel.locationsEntityIdMap.count > 0 {
            if let locationEntityId = trip.entityId {
                if let iconName = knownLocationsModel.locationsEntityIdMap[locationEntityId] {
                    locationIconName = iconName
                }
            }
        }
        
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
        
        locationIcon.image = UIImage(named: locationIconName)
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

