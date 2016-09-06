//
//  MapRouteLineCache.swift
//  LoopTrip
//
//  Created by Scott Seiber on 9/2/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import LoopSDK

typealias MapRouteLineCacheDataModel = [String: [MKPolyline]]
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
    
    func appendPolyLine(entityId: String, polyline: MKPolyline) {
        dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
            if self._polyLineEntityMap[entityId] == nil {
                self._polyLineEntityMap[entityId] = [MKPolyline]()
            }
            
            self._polyLineEntityMap[entityId]!.append(polyline)
        }
    }
    
    func removeEntityData(entityId: String) {
        dispatch_barrier_sync(self.concurrentMapRouteLineCacheQueue) {
            guard self._polyLineEntityMap[entityId] != nil else {
                return
            }

            self._polyLineEntityMap.removeAll()
        }
    }
}
