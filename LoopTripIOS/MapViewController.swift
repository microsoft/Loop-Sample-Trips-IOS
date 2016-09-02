//
//  MapViewController.swift
//  Loop-Sample-Trip-IOS
//

import UIKit
import CoreLocation
import MapKit
import LoopSDK

let MapViewPolylineAddedNotificationNotification = "ms.loop.trip.MapViewPolylineAddedNotification"

public enum RouteAnnotationPosition : Int {
    case startPosition
    case endPosition
}

class LoopPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var showTrips = true
    var tripData:LoopTrip?
    let mapRouteLineCache = MapRouteLineCache.sharedInstance
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.mapView.delegate = self;
        
        self.title = self.showTrips ? "TRIP ROUTE" : "DRIVE ROUTE"

		if let loopTrip = tripData {
            var transportMode = MKDirectionsTransportType.Walking
            if let loopTripTransportMode = loopTrip.transportMode {
                switch loopTripTransportMode {
                    case "driving":
                        transportMode = MKDirectionsTransportType.Automobile
                    case "on_foot":
                        transportMode = MKDirectionsTransportType.Walking
                    case "cycling":
                        transportMode = MKDirectionsTransportType.Automobile
                    default:
                        transportMode = MKDirectionsTransportType.Walking
                }
            }
            
            NSLog("Trip type: \(transportMode)")
            
            let paths = loopTrip.path
            let mapStartEndAnnotations = [
                self.createAnnotationFromLocation(RouteAnnotationPosition.startPosition, loopTripPoint: paths[0]),
                self.createAnnotationFromLocation(RouteAnnotationPosition.endPosition, loopTripPoint: paths[paths.count - 1])
            ]

            if (transportMode == MKDirectionsTransportType.Automobile) {
// throw this into a background queue async
                // create route segments (and overlays) based on mode, speed, and other attributes
                createRouteForMode(paths[0].coordinate, destinationLocation: paths[1].coordinate, routeType: transportMode)
                var index = 0
                repeat {
                    let nextIndex = findNextRoutePointIndex(loopTrip, currentIndex: index)
                    createRouteForMode(paths[index].coordinate, destinationLocation: paths[nextIndex].coordinate, routeType: transportMode)
                    index = nextIndex
                } while index < paths.count - 1
            }
            
// put this into a notification handler (on route done notification)
            // set the map to show start/end annotations
            mapView.showAnnotations(mapStartEndAnnotations, animated: false)

            // set the map to encompass all of our route points
            var mapPoints = paths.enumerate().map {
                index, element in
                return element.coordinate
            }
            let routePolyline = MKPolyline(coordinates: &mapPoints, count: mapPoints.count)
            self.mapView.setRegion(MKCoordinateRegionForMapRect(routePolyline.boundingMapRect), animated: false)
            self.mapView.camera.altitude = self.mapView.camera.altitude * 2.0

            // if walking or biking use the basic polyline instead of route-based line
            if (transportMode != MKDirectionsTransportType.Automobile) {
                self.mapView.addOverlay(routePolyline)
            }
		}
        else {
            NSLog("No trip data set for MapView")
        }
	}
    
    func setData(tripData: LoopTrip, showTrips: Bool) {
        self.tripData = tripData
        self.showTrips = showTrips
    }
    
    func createAnnotationFromLocation(routePosition: RouteAnnotationPosition, loopTripPoint: LoopTripPoint) -> MKPointAnnotation {
        let annotation = LoopPointAnnotation()
		
		annotation.coordinate = loopTripPoint.coordinate
        annotation.title = routePosition == RouteAnnotationPosition.startPosition ? "Starting Location" : "Ending Loction"
		annotation.subtitle = loopTripPoint.timeAt.relativeDayAndTime()
        annotation.imageName = routePosition == RouteAnnotationPosition.startPosition ? "ICO Pin Start" : "ICO Pin End"
        
		return annotation;
	}
    
    func createRouteForMode(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: MKDirectionsTransportType) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = routeType
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    NSLog("Error calculating route line: \(error)")
                }
                
                return
            }
            
            self.mapView.addOverlay(response.routes[0].polyline, level: MKOverlayLevel.AboveRoads)
            NSLog("Created map overlay for new segment")
        }
    }

    func findNextRoutePointIndex(loopTrip: LoopTrip, currentIndex: Int) -> Int {
        let timeOffsetLimit = (60 * 2)      // 2 minutes
        let distanceOffsetLimit = (300.0)   // 300 m ~= 900ft (an estimated city block)
        let averageSpeedLimit = (9.0)       // 9 m/s ~= 20 mph
        let paths = loopTrip.path
        guard currentIndex < paths.count - 1 else {
            return paths.count - 1
        }
        
        for index in currentIndex + 1 ..< paths.count - 1 {
            let timeOffset = paths[index].timeAt.timeIntervalSinceDate(paths[currentIndex].timeAt)
//            if (NSInteger(timeOffset) > timeOffsetLimit) {
//                NSLog("Using time diff constraint: \(paths[index].timeAt.offsetFrom(paths[currentIndex].timeAt))")
//                return index
//            }

            let startLocation = CLLocation.init(latitude: paths[currentIndex].coordinate.latitude, longitude: paths[currentIndex].coordinate.longitude)
            let endLocation = CLLocation.init(latitude: paths[index].coordinate.latitude, longitude: paths[index].coordinate.longitude)
            let distanceOffset = startLocation.distanceFromLocation(endLocation)
            let averageSpeed = distanceOffset / timeOffset

            // ignore segments where travel was less than limit
            if (distanceOffset < distanceOffsetLimit) {
                continue
            }
            
            // keep segment where average speed is below limit
            if (averageSpeed < averageSpeedLimit) {
                NSLog("Using distance diff constraint: \(distanceOffset) m., Speed: \(averageSpeed) m/s.")
                return index
            }
        }
        
        return paths.count - 1
    }
}

	//MARK:- MapViewDelegate methods
extension MapViewController {
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
		polylineRenderer.strokeColor = UIColor.mapRouteLineColor
		polylineRenderer.lineWidth = 4
        polylineRenderer.alpha = 0.70
        
		return polylineRenderer
	}
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isKindOfClass(LoopPointAnnotation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationId = "LoopAnnotation"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationId) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            //annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView?.canShowCallout = true
            
        }
        
        // Set annotation-specific properties **AFTER** the view is dequeued or created...
        let loopPointAnnotation = annotation as! LoopPointAnnotation
        annotationView!.image = UIImage(named: loopPointAnnotation.imageName)
        annotationView!.centerOffset = CGPointMake(0, -15);
        
        return annotationView
    }
}
