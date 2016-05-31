//
//  MapViewController.swift
//  Loop-Sample-Trip-IOS
//
//  Created by Xuwen Cao on 5/30/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import MapKit
import LoopSDK

class LoopPointAnnotation: MKPointAnnotation {
}

class MapViewController: UIViewController {

	@IBOutlet weak var distLabel: UILabel!
	
	@IBOutlet weak var mapView: MKMapView!
	
	var tripData:LoopTrip? = nil;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if tripData != nil {
			distLabel.text = "Distance: \(String(format: "%.3f", tripData!.distanceTraveledInKilometers))Km";
			mapView.showAnnotations(tripData!.path.enumerate().map { index, element in
				return createAnnotationFromLocation(index, location: element)}, animated: false)
		}
	}
	
	func createAnnotationFromLocation(index: Int, location: LoopTripPoint) -> MKPointAnnotation {
		// Add another annotation to the map.
		let annotation = LoopPointAnnotation()
		let dateFormatter = NSDateFormatter();
		dateFormatter.dateFormat = "MM-dd HH:mm";
		
		annotation.coordinate = location.coordinate
		annotation.title = "Point #\(index)"
		annotation.subtitle = "\(dateFormatter.stringFromDate(location.timeAt))"
		
		return annotation;
	}
}
