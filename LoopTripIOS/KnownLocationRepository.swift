//
//  KnownLocationsModel.swift
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
    private var newLocationsEntityIdMap: KnownLocationDataModel = [:]
    
    func loadData(loadDataCompletion: @escaping () -> Void) {
        let dispatchGroupKnownLocation = DispatchGroup()
        dispatchGroupKnownLocation.enter()
        
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            self.newLocationsEntityIdMap.removeAll()
            
            if !loopLocations.isEmpty {
                NSLog("Loop SDK returned \(loopLocations.count) known locations")
                for location in loopLocations {
                    var knownLocationName = "both"
                    for label in location.labels {
                        if label.name == "home" {
                            knownLocationName = "home"
                            break
                        }
                        else if (label.name == "work") {
                            knownLocationName = "work"
                            break
                        }
                    }
                    
                    self.newLocationsEntityIdMap[location.entityId] = knownLocationName
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
    
    func updateData() {
        self.concurrentKnownLocationQueue.sync {
            self._locationsEntityIdMap.removeAll()
            self._locationsEntityIdMap = self.newLocationsEntityIdMap
        }
    }
    
    func removeAllData() {
        self.concurrentKnownLocationQueue.sync {
            self._locationsEntityIdMap.removeAll()
        }
    }
}
