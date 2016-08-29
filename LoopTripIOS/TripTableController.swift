//
//  TripTableController.swift
//  Loop-Sample-Trip-IOS
//

import UIKit
import LoopSDK
import CoreLocation

class TripTableController: UITableViewController {
    var tableData:[(text: String, shouldShowMap: Bool, data:LoopTrip?)] = []
    var showTrips = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we have our own separator
        self.tableView.separatorColor = UIColor.clearColor()
                
        self.tableView.registerNib(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        
        let tripsCompletionCallback = {
            (loopTrips:[LoopTrip]) in
            
            self.tableData.removeAll()
            
            if loopTrips.isEmpty {
                // show sample data
                let sampleTrips = self.loadSampleTripData()
                sampleTrips.forEach { trip in
                    self.tableData.append((text: "", shouldShowMap: true, data: trip))
                }
                
            } else {
                loopTrips.forEach { trip in
                    var locales = ""
                    let start = trip.startLocale?.getFriendlyName()
                    let end = trip.endLocale?.getFriendlyName()
                    if start != nil && end != nil {
                        locales = "\(start!)->\(end!)"
                    }
                    
                    self.tableData.append((text: "\(trip.startedAt.toSimpleString()) \(trip.distanceTraveledInKilometers)Km \(locales)", shouldShowMap:true, data:trip))
                }
            }
            
            self.tableView.reloadData()
        }
        
        if (self.showTrips) {
            LoopSDK.syncManager.getTrips(40, callback: tripsCompletionCallback)
        } else {
            LoopSDK.syncManager.getDrives(40, callback: tripsCompletionCallback)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 87
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        
        if let trip = self.tableData[indexPath.row].data {
            cell.initialize(trip)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        if self.tableData[row].shouldShowMap {
            self.performSegueWithIdentifier(self.showTrips ? "showMapViewForTrips" : "showMapViewForDrives", sender: indexPath)
        } else {
            self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueId = self.showTrips ? "showMapViewForTrips" : "showMapViewForDrives"
        if segue.identifier == segueId, let mapView = segue.destinationViewController as? MapViewController {
            if let indexPath = sender as? NSIndexPath {
                mapView.showTrips = self.showTrips
                mapView.tripData = self.tableData[indexPath.row].data
            }
        }
    }
    
    private func loadSampleTripData() -> [LoopTrip] {
        var loopTrips:[LoopTrip] = [LoopTrip]()
        
        let asset = NSDataAsset(name: self.showTrips ? "SampleTrips" : "SampleDrives", bundle: NSBundle.mainBundle())
        let jsonData = try? NSJSONSerialization.JSONObjectWithData(asset!.data, options: NSJSONReadingOptions.AllowFragments)
        for jsonTrip in jsonData as! [[String: AnyObject]] {
            loopTrips.append(self.createLoopTripFromJSON(jsonTrip))
        }
        
        return loopTrips
    }
    
    func createLoopTripFromJSON(jsonTrip: [String: AnyObject]) -> LoopTrip {
        return LoopTrip(
            entityId: jsonTrip["entityId"] as? String,
            transportMode: jsonTrip["transportMode"] as? String,
            startedAt: (jsonTrip["startedAt"] as! String).toDate(),
            endedAt: (jsonTrip["endedAt"] as! String).toDate(),
            distanceTraveledInKilometers: jsonTrip["distanceTraveledInKilometers"] as! Double,
            userId: jsonTrip["userId"] as! String,
            path: (jsonTrip["path"] as! [[String: AnyObject]]).map { serverPoint in
                return LoopTripPoint(
                    coordinate: CLLocationCoordinate2D.init(
                        latitude: serverPoint["latDegrees"] as! CLLocationDegrees,
                        longitude: serverPoint["longDegrees"] as! CLLocationDegrees),
                    accuracy: serverPoint["accuracyMeters"] as! Double,
                    timeAt: (serverPoint["timeAt"] as! String).toDate()
                )
            },
            startLocale: {
                if let startLocale = jsonTrip["startLocale"] as? [String:String] {
                    return LoopLocale(
                        neighbourhood: startLocale["neighbourhood"],
                        macrohood: startLocale["macrohood"],
                        localadmin: startLocale["localadmin"],
                        locality: startLocale["locality"],
                        metroarea: startLocale["metroarea"],
                        county: startLocale["county"],
                        macrocounty: startLocale["macrocounty"],
                        region: startLocale["region"],
                        country: startLocale["country"])
                } else {
                    return nil;
                }
            }(),
            endLocale: {
                if let endLocale = jsonTrip["endLocale"] as? [String:String] {
                    return LoopLocale(
                        neighbourhood: endLocale["neighbourhood"],
                        macrohood: endLocale["macrohood"],
                        localadmin: endLocale["localadmin"],
                        locality: endLocale["locality"],
                        metroarea: endLocale["metroarea"],
                        county: endLocale["county"],
                        macrocounty: endLocale["macrocounty"],
                        region: endLocale["region"],
                        country: endLocale["country"])
                } else {
                    return nil;
                }
            }()
        );
    }
}

