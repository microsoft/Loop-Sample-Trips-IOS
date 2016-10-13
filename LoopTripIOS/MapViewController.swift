//
//  MapViewController.swift
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

    @IBOutlet weak var tripDetailsView: MapDetailsView!
    @IBOutlet weak var tripDetailsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!

    private var mapViewUpdateObserver: NSObjectProtocol!
    
    var tripData: LoopTrip?
    var rowIndex = -1
    var isSample: Bool = false
    var transportMode = MKDirectionsTransportType.walking
    let mapRouteLineCache = MapRouteLineCache.sharedInstance
    let knownLocationRepository = KnownLocationRepository.sharedInstance
	
    override func viewWillDisappear(_ animated: Bool) {
        if let mapViewUpdateObserver = mapViewUpdateObserver {
            NotificationCenter.default.removeObserver(mapViewUpdateObserver)
        }
    }

    override func viewDidLoad() {
		super.viewDidLoad()
        
        self.title = "TRIP ROUTE".localized
        
        self.tripDetailsView.layer.shadowOpacity = 0.4
        self.tripDetailsView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.tripDetailsView.setData(trip: self.tripData!, rowIndex: self.rowIndex, sampleTrip: self.isSample)
        self.tripDetailsView.layoutIfNeeded()
        
        // adjust height of details view based on whether this is a sample trip
        if (self.isSample) {
            tripDetailsViewHeightConstraint.constant += 26
        }
        
        self.mapView.delegate = self
        
        mapViewUpdateObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MapRouteLineCacheAddedContentNotification), object: nil, queue: OperationQueue.main) {
            notification in
            self.contentChangedNotification(notification: notification as NSNotification!)
        }
        
		if let loopTrip = self.tripData {
            if let loopTripTransportMode = loopTrip.transportMode {
                switch loopTripTransportMode {
                    case "driving":
                        transportMode = MKDirectionsTransportType.automobile
                    case "on_foot":
                        transportMode = MKDirectionsTransportType.walking
                    case "cycling":
                        transportMode = MKDirectionsTransportType.automobile
                    default:
                        transportMode = MKDirectionsTransportType.walking
                }
            }
            
            NSLog("Trip type: \(transportMode)")

            // for now we're going to just draw the raw data polylines
            self.setMapView()
            
//            if (transportMode == MKDirectionsTransportType.Automobile) {
//                self.createRoutePathsAsync()
//            }
//            else {
//                self.setMapView()
//            }
		}
        else {
            NSLog("No trip data set for MapView")
        }
	}
}


// MARK - Internal

extension MapViewController {
    func setData(tripData: LoopTrip, rowIndex: Int, isSample: Bool) {
        self.tripData = tripData
        self.isSample = isSample
    }
    
    fileprivate func contentChangedNotification(notification: NSNotification!) {
        switch notification.name.rawValue {
        case MapRouteLineCacheAddedContentNotification:
            NSLog("Received update notification in MapView")
            self.setMapView()
        default:
            NSLog("Unknown notification")
        }
    }
    
    fileprivate func createAnnotationFromLocation(routePosition: RouteAnnotationPosition, loopTripPoint: LoopTripPoint) -> MKPointAnnotation {
        let annotation = LoopPointAnnotation()
		
		annotation.coordinate = loopTripPoint.coordinate
        annotation.title = routePosition == RouteAnnotationPosition.startPosition ? "Starting Location".localized : "Ending Location".localized
		annotation.subtitle = loopTripPoint.timeAt.relativeDayAndTime()
        annotation.imageName = routePosition == RouteAnnotationPosition.startPosition ? "ICO Pin Start Small" : "ICO Pin End Small"
        
		return annotation
	}
    
    fileprivate func createRoutePathsAsync() {
        if let loopTrip = self.tripData {
            let paths = loopTrip.path
            
            if let entityId = loopTrip.entityId {
                // check in the cache first
                if let polylines = mapRouteLineCache.polyLineEntityMap[entityId] {
                    NSLog("Found cached polylines")

                    for polyline in polylines {
                        self.mapView.add(polyline, level: MKOverlayLevel.aboveRoads)
                    }
                }
                else {
                    NSLog("Creating new route polylines")
                    
                    // create route segments (and overlays) based on mode, speed, and other attributes
                    createRouteForMode(sourceLocation: paths[0].coordinate, destinationLocation: paths[1].coordinate, routeType: transportMode)
                    var index = 0
                    repeat {
                        let nextIndex = findNextRoutePointIndex(loopTrip: loopTrip, currentIndex: index)
                        createRouteForMode(sourceLocation: paths[index].coordinate, destinationLocation: paths[nextIndex].coordinate, routeType: transportMode)
                        index = nextIndex
                    } while index < paths.count - 1
                }
            }
        }
        
        NSLog("Sending update notification for automobile route")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MapRouteLineCacheAddedContentNotification), object: nil)
    }
    
    fileprivate func createRouteForMode(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: MKDirectionsTransportType) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = routeType
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    NSLog("Error calculating route line: \(error)")
                }
                
                return
            }
            
            self.mapView.add(response.routes[0].polyline, level: MKOverlayLevel.aboveRoads)
            if let loopTrip = self.tripData {
                if let entityId = loopTrip.entityId {
                    self.mapRouteLineCache.appendPolyLine(entityId: entityId, polyline: response.routes[0].polyline)
                }
            }
            
            NSLog("Created map overlay for new segment")
        }
    }

    fileprivate func findNextRoutePointIndex(loopTrip: LoopTrip, currentIndex: Int) -> Int {
        let distanceOffsetLimit = (300.0)   // 300 m ~= 900ft (an estimated city block)
        let averageSpeedLimit = (13.0)       // 13 m/s ~= 29 mph
        let paths = loopTrip.path
        guard currentIndex < paths.count - 1 else {
            return paths.count - 1
        }
        
        for index in currentIndex + 1 ..< paths.count - 1 {
            let distanceOffset = pathDistanceOffset(startPoint: paths[index - 1].coordinate, endPoint: paths[index].coordinate)
            let averageSpeed = distanceOffset / pathTimeOffset(startPoint: paths[index - 1], endPoint: paths[index])

            // ignore segments where travel was less than limit
            if (distanceOffset < distanceOffsetLimit) {
                NSLog("Ignoring segment based on distance (D: \(distanceOffset) m S: \(averageSpeed) m/s)")
                continue
            }
            
            // ignore segments where speed is below limit
            if (averageSpeed < averageSpeedLimit) {
                NSLog("Ignoring segment based on speed (D: \(distanceOffset) m S: \(averageSpeed) m/s)")
                continue
            }
            
            // keep segment where average speed is below limit
            NSLog("Keeping segment (D: \(distanceOffset) m S: \(averageSpeed) m/s)")
            return index
        }
        
        return paths.count - 1
    }
    
    fileprivate func pathTimeOffset(startPoint: LoopTripPoint, endPoint: LoopTripPoint) -> TimeInterval {
        return endPoint.timeAt.timeIntervalSince(startPoint.timeAt)
    }
    
    fileprivate func pathDistanceOffset(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: startPoint.latitude, longitude: startPoint.longitude)
        let endLocation = CLLocation(latitude: endPoint.latitude, longitude: endPoint.longitude)
        return startLocation.distance(from: endLocation)
    }
    
    fileprivate func setMapView() {
        if let loopTrip = self.tripData {
            let paths = loopTrip.path
            
            // set the map to show start/end annotations
            let mapStartEndAnnotations = [
                self.createAnnotationFromLocation(routePosition: RouteAnnotationPosition.startPosition, loopTripPoint: paths[0]),
                self.createAnnotationFromLocation(routePosition: RouteAnnotationPosition.endPosition, loopTripPoint: paths[paths.count - 1])
            ]
            
            self.mapView.showAnnotations(mapStartEndAnnotations, animated: false)
            
            // set the map to encompass all of our route points
            var mapPoints = paths.enumerated().map {
                index, element in
                return element.coordinate
            }
            let routePolyline = MKPolyline(coordinates: &mapPoints, count: mapPoints.count)
            
            self.mapView.setRegion(MKCoordinateRegionForMapRect(routePolyline.boundingMapRect), animated: false)
            self.mapView.camera.altitude = self.mapView.camera.altitude * 4.0
            
            // if walking or biking use the basic polyline instead of route-based line
            //if (self.transportMode != MKDirectionsTransportType.Automobile) {
                self.mapView.add(routePolyline)
            //}
        }
    }
}


// MARK:- MapViewDelegate

extension MapViewController {
    @objc(mapView:rendererForOverlay:) public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.mapRouteLineColor
        polylineRenderer.lineWidth = 4
        polylineRenderer.alpha = 0.30
        
        return polylineRenderer
    }
    
    // mapView:viewForAnnotation: provides the view for each annotation.
    // This method may be called for all or some of the added annotations.
    // For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
    @objc(mapView:viewForAnnotation:) public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isKind(of: LoopPointAnnotation.self) else {
            return nil
        }
        
        // Better to make this class property
        let annotationId = "LoopAnnotation"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) {
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
        annotationView!.centerOffset = CGPoint(x: 0, y: -15)
        
        return annotationView
    }
}
