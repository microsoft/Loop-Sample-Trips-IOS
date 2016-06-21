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

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var distLabel: UILabel!
	
	@IBOutlet weak var mapView: MKMapView!
	
	var tripData:LoopTrip? = nil;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if tripData != nil {
			var transportMode = "on_foot"
			if let mode = tripData!.transportMode {
				transportMode = mode;
			}
			distLabel.text = "Distance: \(String(format: "%.3f", tripData!.distanceTraveledInKilometers))Km(\(transportMode))";
			mapView.showAnnotations(tripData!.path.enumerate().map { index, element in
				return createAnnotationFromLocation(index, location: element)}, animated: false)
			var points = tripData!.path.map { return $0.coordinate }
			let polyline = MKPolyline(coordinates: &points, count: points.count)
			mapView.addOverlay(polyline)
			mapView.delegate = self;
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
	
	//MARK:- MapViewDelegate methods
 
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
		polylineRenderer.strokeColor = UIColor.blueColor()
		polylineRenderer.lineWidth = 2
		return polylineRenderer
	}
}
