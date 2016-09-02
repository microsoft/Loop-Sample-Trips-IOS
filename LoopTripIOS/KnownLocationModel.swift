//
//  KnownLocationsModel.swift
//  LoopTrip

import Foundation
import CoreLocation
import LoopSDK

typealias KnownLocationDataModel = [String: String]
let KnownLocationModelAddedContentNotification = "ms.loop.trip.KnownLocationModelAddedContentNotification"

public class KnownLocationModel {
    static let sharedInstance = KnownLocationModel()
    private init() {}
    private let concurrentKnownLocationQueue = dispatch_queue_create("ms.loop.trip.KnownLocationModelQueue", DISPATCH_QUEUE_CONCURRENT)
    var sampleData = false
    private var _locationsEntityIdMap: KnownLocationDataModel = [:]
    var locationsEntityIdMap: KnownLocationDataModel {
        var locationsEntityIdMapCopy: KnownLocationDataModel!
        dispatch_sync(concurrentKnownLocationQueue) {
            locationsEntityIdMapCopy = self._locationsEntityIdMap
        }
        return locationsEntityIdMapCopy
    }
    
    func loadData() {
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            dispatch_barrier_sync(self.concurrentKnownLocationQueue) {
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
                    
                    dispatch_barrier_sync(self.concurrentKnownLocationQueue) {
                        self._locationsEntityIdMap[location.entityId] = knownLocationName
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(KnownLocationModelAddedContentNotification, object: nil)
        }
    }
}
