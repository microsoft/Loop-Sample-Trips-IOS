//
//  TripModel.swift
//  Loop-Trip

import Foundation
import CoreLocation
import LoopSDK

public class TripModel {
    static let sharedInstance = TripModel()
    private init() {}
    var sampleData = false
    var tableData:[(shouldShowMap: Bool, isSampleData: Bool, data:LoopTrip?)] = []
    
    public func loadData(isTrips: Bool, loadDataCompletion: () -> Void) {
        let getTripsCompletion = {
            (loopTrips:[LoopTrip]) in
            
            self.tableData.removeAll()
            
            if loopTrips.isEmpty {
                self.sampleData = true
                
                let sampleTrips = self.loadSampleTripData()
                sampleTrips.forEach { trip in
                    self.tableData.append((shouldShowMap: true, isSampleData: true, data: trip))
                }
            } else {
                loopTrips.forEach { trip in
                    self.tableData.append((shouldShowMap:true, isSampleData: false, data:trip))
                }
            }
            
            loadDataCompletion()
        }
        
        if (isTrips) {
            LoopSDK.syncManager.getTrips(40, callback: getTripsCompletion)
        } else {
            LoopSDK.syncManager.getDrives(40, callback: getTripsCompletion)
        }
    }
    
    private func loadSampleTripData() -> [LoopTrip] {
        var loopTrips:[LoopTrip] = [LoopTrip]()
        
        let asset = NSDataAsset(name: self.sampleData ? "SampleTrips" : "SampleDrives", bundle: NSBundle.mainBundle())
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
