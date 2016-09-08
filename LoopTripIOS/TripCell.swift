//
//  TripCell.swift
//  LoopTrip
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
    @IBOutlet weak var startLocationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endLocationWidthConstraint: NSLayoutConstraint!
    
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.tableCellBackgroundColorLight
    }
    
    func setData(trip: LoopTrip, sampleTrip: Bool) {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        if (!sampleTrip) {
            sampleTripIndicator.hidden = true
        }
        
        setLocaleLabels(trip)
        
        self.locationDistance.text = " \(ConversionUtils.kilometersToMiles(trip.distanceTraveledInKilometers)) mi. "
        self.locationDuration.text = trip.endedAt.offsetFrom(trip.startedAt)
        self.locationTime.text = trip.startedAt.relativeDayAndStartEndTime(trip.endedAt)
    }
    
    func setLocaleLabels(trip: LoopTrip) {
        var locationIconName = "ICO Cell Blank"
        
        if knownLocationRepository.locationsEntityIdMap.count > 0 {
            if let locationEntityId = trip.entityId {
                if let iconName = knownLocationRepository.locationsEntityIdMap[locationEntityId] {
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
        
        adjustLocationLabelConstraints()
        
        locationIcon.image = UIImage(named: locationIconName)
    }
    
    private func setStartLocaleLabelText(text: String) {
        self.startLocation.text = text
    }
    
    private func setEndLocaleLabelText(text: String) {
        self.endLocation.text = text
    }
    
    private func adjustEndLocaleLabelText(removeLabel: Bool) {
        var adjustConstraintConstant = CGFloat.init(10)
        
        if (removeLabel) {
            adjustConstraintConstant = CGFloat.init(0)
        }
        
        self.endLocation.hidden = removeLabel
        self.endLocationLeadingConstraint.constant = adjustConstraintConstant
        
        self.destinationArrow.hidden = removeLabel
        self.destinationArrowLeadingConstraint.constant = adjustConstraintConstant
    }
    
    private func adjustLocationLabelConstraints() {
        let totalLabelsWidth = CGFloat.init(200)
        let singleLabelWidth = (totalLabelsWidth / 2)
        let startLabelWidth = createAttributedString(self.startLocation.text!).widthWithConstrainedHeight(18.0)
        let endLabelWidth = createAttributedString(self.endLocation.text!).widthWithConstrainedHeight(18.0)
        
        if (self.endLocation.hidden == true) {
            startLocationWidthConstraint.constant = totalLabelsWidth
        }
        else {
            if (startLabelWidth + endLabelWidth <= totalLabelsWidth) {
                startLocationWidthConstraint.constant = startLabelWidth
                endLocationWidthConstraint.constant = endLabelWidth
            }
            else {
                if (startLabelWidth < singleLabelWidth) {
                    startLocationWidthConstraint.constant = startLabelWidth
                    endLocationWidthConstraint.constant = totalLabelsWidth - startLabelWidth
                }
                else if (endLabelWidth < singleLabelWidth) {
                    endLocationWidthConstraint.constant = endLabelWidth
                    startLocationWidthConstraint.constant = totalLabelsWidth - endLabelWidth
                }
                else {
                    endLocationWidthConstraint.constant = singleLabelWidth
                    startLocationWidthConstraint.constant = singleLabelWidth
                }
            }
        }
    }
    
    private func createAttributedString(text: String) -> NSAttributedString {
        let linkAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: 16.0)!,
        ]
        
        return NSAttributedString.init(string: text, attributes: linkAttributes)
    }
}
