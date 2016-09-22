//
//  JSON.swift
//  JSON utilities
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

import Foundation
import CoreLocation
import LoopSDK

class JSONUtils {
    class func loadSampleTripData(sampleName: String) -> [LoopTrip] {
        var loopTrips:[LoopTrip] = [LoopTrip]()
        
        let asset = NSDataAsset(name: sampleName, bundle: Bundle.main)
        let jsonData = try? JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments)
        for jsonTrip in jsonData as! [[String: AnyObject]] {
            loopTrips.append(self.createLoopTripFromJSON(jsonTrip: jsonTrip))
        }
        
        return loopTrips
    }
    
    class func testTripData() -> LoopTrip {
        let jsonString = ""
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        let loopTripJson = try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)
        let loopTrip = createLoopTripFromJSON(jsonTrip: loopTripJson as! [String: AnyObject])
        return loopTrip
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
