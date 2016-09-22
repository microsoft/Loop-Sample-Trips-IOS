//
//  TripCell.swift
//  Trips App
//
//  Copyright (c) 2016 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
import LoopSDK

class TripCell: UITableViewCell {
        
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var startLocationWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var startLocationIcon: UIImageView!
    @IBOutlet weak var startLocationIconLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var destinationArrow: UIImageView!
    @IBOutlet weak var destinationArrowLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var endLocationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endLocationLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var endLocationIcon: UIImageView!
    @IBOutlet weak var endLocationIconLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationDuration: UILabel!
    @IBOutlet weak var sampleTripIndicator: UILabel!
    
    
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    
    override func awakeFromNib () {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.tableCellBackgroundColorLight
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setData(trip: LoopTrip, isSample: Bool) {
        if (!isSample) {
            sampleTripIndicator.isHidden = true
        }
        
        self.locationDistance.text = " \(ConversionUtils.kilometersToMiles(kilometers: trip.distanceTraveledInKilometers)) mi. "
        self.locationDuration.text = trip.endedAt.offsetFrom(endDate: trip.startedAt)
        self.locationTime.text = trip.startedAt.relativeDayAndStartEndTime(endDate: trip.endedAt)

        setLocationLabels(trip: trip)
    }
    
    private func setLocationLabels(trip: LoopTrip) {
        if (setStartLocationLabel(trip: trip) == setEndLocationLabel(trip: trip)) {
            removeEndLocationLabel()
        }
        
        adjustLocationLabelConstraints()
    }
    
    private func setStartLocationLabel(trip: LoopTrip) -> String {
        if let startLocationText = trip.startLocale?.getFriendlyName().uppercased() {
            self.startLocationLabel.text = startLocationText
            
            if let locationEntityId = trip.startLocationEntityId {
                let locationIconName = getIconNameFromLocationEntityId(locationEntityId: locationEntityId)
                
                if (locationIconName != "unknown") {
                    startLocationIcon.image = UIImage(named: locationIconName)
                }
                else {
                    startLocationIcon.removeFromSuperview()
                }
            }
            else {
                startLocationIcon.removeFromSuperview()
            }
        }
        
        return self.startLocationLabel.text!
    }
    
    private func setEndLocationLabel(trip: LoopTrip) -> String {
        if let endLocationText = trip.endLocale?.getFriendlyName().uppercased() {
            self.endLocationLabel.text = endLocationText
            
            if let locationEntityId = trip.endLocationEntityId {
                let locationIconName = getIconNameFromLocationEntityId(locationEntityId: locationEntityId)

                if (locationIconName != "unknown") {
                    endLocationIcon.image = UIImage(named: locationIconName)
                }
                else {
                    endLocationIcon.removeFromSuperview()
                }
            }
            else {
                endLocationIcon.removeFromSuperview()
            }
        }
        
        return self.endLocationLabel.text!
    }
    
    private func removeEndLocationLabel() {
        self.endLocationIcon.isHidden = true
        self.endLocationIconLeadingConstraint.constant = CGFloat(0)

        self.endLocationLabel.isHidden = true
        self.endLocationLeadingConstraint.constant = CGFloat(0)
        
        self.destinationArrow.isHidden = true
        self.destinationArrowLeadingConstraint.constant = CGFloat(0)
    }
    
    private func adjustLocationLabelConstraints() {
        let startLabelWidth = createAttributedString(text: self.startLocationLabel.text!, textSize: 16.0).widthWithConstrainedHeight(height: 18.0)
        let endLabelWidth = createAttributedString(text: self.endLocationLabel.text!, textSize: 16.0).widthWithConstrainedHeight(height: 18.0)
        let distanceLabelWidth = createAttributedString(text: self.locationDistance.text!, textSize: 12.0).widthWithConstrainedHeight(height: 12.0)
        let totalLabelsWidth = CGFloat.init(self.bounds.size.width - (distanceLabelWidth + 70))
        let singleLabelWidth = (totalLabelsWidth / 2)
        
        if (self.endLocationLabel.isHidden == true) {
            if (startLabelWidth < totalLabelsWidth) {
                startLocationWidthConstraint.constant = startLabelWidth
            }
            else {
                startLocationWidthConstraint.constant = totalLabelsWidth
            }
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
    
    private func getIconNameFromLocationEntityId(locationEntityId: String) -> String {
        var locationIconName = "unknown"

        let knownLocation = self.knownLocationRepository.getKnownLocationForTripDestination(locationEntityId: locationEntityId)
        switch knownLocation {
        case "both":
            locationIconName = "ICO Cell Both"
            
        case "home":
            locationIconName = "ICO Cell Home"
            
        case "work":
            locationIconName = "ICO Cell Work"
            
        default:
            locationIconName = "unknown"
        }
        
        return locationIconName
    }
    
    private func createAttributedString(text: String, textSize: CGFloat) -> NSAttributedString {
        let linkAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: textSize)!,
        ]
        
        return NSAttributedString.init(string: text, attributes: linkAttributes)
    }
}
