//
//  MapRouteLineCache.swift
//  LoopTrip
//
//  Created by Scott Seiber on 9/2/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import CoreLocation
import LoopSDK

typealias MapRouteLineCacheDataModel = [String: String]
let MapRouteLineCacheAddedContentNotification = "ms.loop.trip.MapRouteLineCacheAddedContentNotification"

public class MapRouteLineCache {
    static let sharedInstance = MapRouteLineCache()
    private init() {}
    private let concurrentMapRouteLineCacheQueue = dispatch_queue_create("ms.loop.trip.MapRouteLineCacheQueue", DISPATCH_QUEUE_CONCURRENT)
    var sampleData = false
    private var _locationsEntityIdMap: MapRouteLineCacheDataModel = [:]
    var locationsEntityIdMap: MapRouteLineCacheDataModel {
        var locationsEntityIdMapCopy: MapRouteLineCacheDataModel!
        dispatch_sync(concurrentMapRouteLineCacheQueue) {
            locationsEntityIdMapCopy = self._locationsEntityIdMap
        }
        return locationsEntityIdMapCopy
    }
    
    func loadData() {
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
                self._locationsEntityIdMap.removeAll()
            }
            
            if !loopLocations.isEmpty {
                NSLog("Loop SDK returned \(loopLocations.count) known locations")
                for location in loopLocations {
                    var knownLocationName = "ICO Cell Both"
                    for label in location.labels {
                        if label.name == "home" {
                            knownLocationName = "ICO Cell Home"
                            break;
                        }
                        else if (label.name == "work") {
                            knownLocationName = "ICO Cell Work"
                            break;
                        }
                    }
                    
                    dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
                        self._locationsEntityIdMap[location.entityId] = knownLocationName
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(MapRouteLineCacheAddedContentNotification, object: nil)
        }
    }
}
