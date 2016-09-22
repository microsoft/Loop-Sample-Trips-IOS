//
//  MapRouteLineCache.swift
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
import MapKit
import LoopSDK

typealias MapRouteLineCacheDataModel = [String: [MKPolyline]]
let MapRouteLineCacheAddedContentNotification = "ms.loop.trip.MapRouteLineCacheAddedContentNotification"

public class MapRouteLineCache {
    static let sharedInstance = MapRouteLineCache()
    private init() {}
    private let concurrentMapRouteLineCacheQueue = DispatchQueue(label: "ms.loop.trip.MapRouteLineCacheQueue", attributes: .concurrent)
    private var _polyLineEntityMap: MapRouteLineCacheDataModel = [:]
    var polyLineEntityMap: MapRouteLineCacheDataModel {
        var polyLineEntityMapCopy: MapRouteLineCacheDataModel!
        concurrentMapRouteLineCacheQueue.sync {
            polyLineEntityMapCopy = self._polyLineEntityMap
        }
        return polyLineEntityMapCopy
    }
    
    func appendPolyLine(entityId: String, polyline: MKPolyline) {
        self.concurrentMapRouteLineCacheQueue.sync {
            if self._polyLineEntityMap[entityId] == nil {
                self._polyLineEntityMap[entityId] = [MKPolyline]()
            }
            
            self._polyLineEntityMap[entityId]!.append(polyline)
        }
    }
    
    func removeEntityData(entityId: String) {
        self.concurrentMapRouteLineCacheQueue.sync {
            guard self._polyLineEntityMap[entityId] != nil else {
                return
            }

            self._polyLineEntityMap.removeAll()
        }
    }
}
