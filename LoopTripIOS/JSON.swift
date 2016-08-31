//
//  JSON.swift
//  JSON utilities
//  Loop Trips Sample
//

import Foundation
import CoreLocation
import LoopSDK

class JSONUtils {
    class func loadSampleTripData(sampleName: String) -> [LoopTrip] {
        var loopTrips:[LoopTrip] = [LoopTrip]()
        
        let asset = NSDataAsset(name: sampleName, bundle: NSBundle.mainBundle())
        let jsonData = try? NSJSONSerialization.JSONObjectWithData(asset!.data, options: NSJSONReadingOptions.AllowFragments)
        for jsonTrip in jsonData as! [[String: AnyObject]] {
            loopTrips.append(self.createLoopTripFromJSON(jsonTrip))
        }
        
        return loopTrips
    }
    
    internal class func createLoopTripFromJSON(jsonTrip: [String: AnyObject]) -> LoopTrip {
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
            }(),
            startLocationEntityId: jsonTrip["startLocationEntityId"] as? String,
            endLocationEntityId: jsonTrip["endLocationEntityId"] as? String
        );
    }
}
