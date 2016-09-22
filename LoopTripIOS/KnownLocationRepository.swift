//
//  KnownLocationsModel.swift
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

typealias KnownLocationDataModel = [String: String]
let KnownLocationRepositoryAddedContentNotification = "ms.loop.trip.KnownLocationRepositoryAddedContentNotification"

public class KnownLocationRepository {
    static let sharedInstance = KnownLocationRepository()
    private init() {}
    private let concurrentKnownLocationQueue = DispatchQueue(label: "ms.loop.trip.KnownLocationRepositoryQueue", attributes: .concurrent)
    private var _locationsEntityIdMap: KnownLocationDataModel = [:]
    var locationsEntityIdMap: KnownLocationDataModel {
        var locationsEntityIdMapCopy: KnownLocationDataModel!
        concurrentKnownLocationQueue.sync {
            locationsEntityIdMapCopy = self._locationsEntityIdMap
        }
        return locationsEntityIdMapCopy
    }
    
    func loadData(loadDataCompletion: @escaping () -> Void) {
        let dispatchGroupKnownLocation = DispatchGroup()
        dispatchGroupKnownLocation.enter()
        
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            self.concurrentKnownLocationQueue.sync {
                self._locationsEntityIdMap.removeAll()
            }
            
            if !loopLocations.isEmpty {
                NSLog("Loop SDK returned \(loopLocations.count) known locations")
                for location in loopLocations {
                    var knownLocationName = "both"
                    for label in location.labels {
                        if label.name == "home" {
                            knownLocationName = "home"
                            break;
                        }
                        else if (label.name == "work") {
                            knownLocationName = "work"
                            break;
                        }
                    }
                    
                    self.concurrentKnownLocationQueue.sync {
                        self._locationsEntityIdMap[location.entityId] = knownLocationName
                    }
                }
            }
            
            dispatchGroupKnownLocation.leave()
        }
        
        dispatchGroupKnownLocation.notify(queue: DispatchQueue.main, execute: {
            loadDataCompletion()
        })
    }
    
    func getKnownLocationForTripDestination(locationEntityId: String) -> String {
        if (locationsEntityIdMap.count > 0) {
            if let locationName = locationsEntityIdMap[locationEntityId] {
                return locationName
            }
        }
        
        return "unknown"
    }
}
