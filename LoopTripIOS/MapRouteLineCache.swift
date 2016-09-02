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
    private var _polyLineEntityMap: MapRouteLineCacheDataModel = [:]
    var polyLineEntityMap: MapRouteLineCacheDataModel {
        var polyLineEntityMapCopy: MapRouteLineCacheDataModel!
        dispatch_sync(concurrentMapRouteLineCacheQueue) {
            polyLineEntityMapCopy = self._polyLineEntityMap
        }
        return polyLineEntityMapCopy
    }
    
    func addPolyLine() {
        dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
            self._polyLineEntityMap["foo"] = "bar"
        }
    }
    
    func appendPolyLine() {
        dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
            self._polyLineEntityMap["foo"] = "bar"
        }
    }
    
    func removeEntityData() {
        dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
            self._polyLineEntityMap.removeAll()
        }
    }
}
