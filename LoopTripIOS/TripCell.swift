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
    @IBOutlet weak var endLocationLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var destinationArrowLeadingConstraint: NSLayoutConstraint!
    
    let leadingConstraintConstant: CGFloat = 10.0
    let knownLocationsModel = KnownLocationModel.sharedInstance
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.tableCellBackgroundColorLight
    }
    
    func setData(trip: LoopTrip, sampleTrip: Bool) {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        if (!sampleTrip) {
            sampleTripIndicator.hidden = true
        }
        
        setLocaleLabel(trip)
        
        self.locationDistance.text = " \(ConversionUtils.kilometersToMiles(trip.distanceTraveledInKilometers)) mi. "
        self.locationDuration.text = trip.endedAt.offsetFrom(trip.startedAt)
        self.locationTime.text = trip.startedAt.relativeDayAndStartEndTime(trip.endedAt)
    }
    
    func setLocaleLabel(trip: LoopTrip) {
        var locationIconName = "ICO Cell Blank"
        
        if knownLocationsModel.locationsEntityIdMap.count > 0 {
            if let locationEntityId = trip.entityId {
                if let iconName = knownLocationsModel.locationsEntityIdMap[locationEntityId] {
                    locationIconName = iconName
                }
            }
        }
        
        if let startLocaleText = trip.startLocale?.getFriendlyName().uppercaseString {
            setStartLocaleLabelText(startLocaleText)

            if let endLocaleText = trip.endLocale?.getFriendlyName().uppercaseString {
                if (endLocaleText != startLocaleText) {
                    adjustEndLocaleLabelText(false)
                    setEndLocaleLabelText(endLocaleText)
                }
                else {
                    adjustEndLocaleLabelText(true)
                }
            }
            else {
                adjustEndLocaleLabelText(true)
            }
        } else {
            adjustEndLocaleLabelText(true)
            setStartLocaleLabelText("UNKONWN")
        }
        
        locationIcon.image = UIImage(named: locationIconName)
    }
    
    private func setStartLocaleLabelText(text: String) {
        self.startLocation.text = text
    }
    
    private func setEndLocaleLabelText(text: String) {
        self.endLocation.text = text
    }
    
    private func adjustEndLocaleLabelText(removeLabel: Bool) {
        let adjustConstraintConstant = removeLabel ? 0 : self.leadingConstraintConstant
        
        self.endLocation.hidden = removeLabel
        self.endLocationLeadingConstraint.constant = adjustConstraintConstant
        
        self.destinationArrow.hidden = removeLabel
        self.destinationArrowLeadingConstraint.constant = adjustConstraintConstant
    }
}

