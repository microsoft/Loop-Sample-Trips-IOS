//
//  MapDetails.swift
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
    @IBOutlet weak var startLocationIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var destinationArrow: UIImageView!
    @IBOutlet weak var destinationArrowLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var endLocationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endLocationLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var endLocationIcon: UIImageView!
    @IBOutlet weak var endLocationIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var endLocationIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationDuration: UILabel!
    @IBOutlet weak var sampleTripIndicator: UILabel!
    
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    var rowIndex = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MapDetailsView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    func setData(trip: LoopTrip, rowIndex: Int, sampleTrip: Bool) {
        self.rowIndex = rowIndex

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
        var startLocation = "Unknown".localized
        if let startLocationText = trip.startLocale?.getFriendlyName().uppercased() {
            startLocation = startLocationText
        }
        
        self.startLocationLabel.text = startLocation
        
        if let locationEntityId = trip.startLocationEntityId {
            let locationIconName = getIconNameFromLocationEntityId(locationEntityId: locationEntityId)
            
            if (locationIconName != "unknown") {
                self.startLocationIcon.image = UIImage(named: locationIconName)
                self.startLocationIcon.isHidden = false
                self.startLocationIconWidthConstraint.constant = CGFloat(16)
            }
            else {
                self.startLocationIcon.isHidden = true
                self.startLocationIconWidthConstraint.constant = 0
            }
        }
        else {
            self.startLocationIcon.isHidden = true
            self.startLocationIconWidthConstraint.constant = 0
        }
        
        return startLocation
    }
    
    private func setEndLocationLabel(trip: LoopTrip) -> String {
        var endLocation = "Unknown".localized
        if let endLocationText = trip.endLocale?.getFriendlyName().uppercased() {
            endLocation = endLocationText
        }
        
        self.endLocationLabel.text = endLocation
        
        if let locationEntityId = trip.endLocationEntityId {
            let locationIconName = getIconNameFromLocationEntityId(locationEntityId: locationEntityId)
            
            if (locationIconName != "unknown") {
                self.endLocationIcon.image = UIImage(named: locationIconName)
                self.endLocationIcon.isHidden = false
                self.endLocationIconWidthConstraint.constant = CGFloat(16)
            }
            else {
                self.endLocationIcon.isHidden = true
                self.endLocationIconWidthConstraint.constant = 0
            }
        }
        else {
            self.endLocationIcon.isHidden = true
            self.endLocationIconWidthConstraint.constant = 0
        }
        
        return endLocation
    }
    
    private func removeEndLocationLabel() {
        self.endLocationIcon.isHidden = true
        self.endLocationWidthConstraint.constant = CGFloat(0)
        self.endLocationIconLeadingConstraint.constant = CGFloat(0)
        
        self.endLocationLabel.isHidden = true
        self.endLocationLeadingConstraint.constant = CGFloat(0)
        
        self.destinationArrow.isHidden = true
        self.destinationArrowLeadingConstraint.constant = CGFloat(0)
    }
    
    private func adjustLocationLabelConstraints() {
        // This table has a fixed layout and font size. A better approach to respect accessibility would be to respond
        // to the UIContentSizeCategoryDidChange notification and map the new size category to an appropriate size in
        // the custom font used here.

        let startLabelWidth = createAttributedString(text: self.startLocationLabel.text!, textSize: 16.0).widthWithConstrainedHeight(height: 18.0)
        let endLabelWidth = createAttributedString(text: self.endLocationLabel.text!, textSize: 16.0).widthWithConstrainedHeight(height: 18.0)
        let distanceLabelWidth = createAttributedString(text: self.locationDistance.text!, textSize: 12.0).widthWithConstrainedHeight(height: 12.0)
        let cellWidthRemaining = 100
            + self.startLocationIconWidthConstraint.constant + 5
            + self.endLocationIconWidthConstraint.constant + 5
        let totalLabelsWidth = CGFloat(self.frame.size.width - (distanceLabelWidth + cellWidthRemaining))
        let singleLabelWidth = (totalLabelsWidth / 2)
        
        
NSLog("mapDetailsView width \(self.frame.size.width)")
        
        
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
        
        return NSAttributedString(string: text, attributes: linkAttributes)
    }
}
