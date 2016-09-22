//
//  MapDetails.swift
//  Trips App
//
//  Copyright (c) Microsoft Corporation
//
//  All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the License); you may not
//  use this file except in compliance with the License. You may obtain a copy
//  of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
//  OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY
//  IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
//  MERCHANTABLITY OR NON-INFRINGEMENT.
//
//  See the Apache Version 2.0 License for specific language governing permissions
//  and limitations under the License.
//

// This implementation was duplicated directly from this project's TripCell.swift
// implementation vs. creating a common shared class. It was originally thought the
// map details view could change significantly from the table cell view.

import Foundation
import UIKit
import LoopSDK

class MapDetailsView: UIView {
    @IBOutlet var contentView: UIView!
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        //self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        
        Bundle.main.loadNibNamed("MapDetailsView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    func setData(trip: LoopTrip, sampleTrip: Bool) {
        if (!sampleTrip) {
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
