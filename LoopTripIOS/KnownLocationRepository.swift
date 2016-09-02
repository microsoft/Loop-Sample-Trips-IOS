//
//  KnownLocationsModel.swift
//  LoopTrip

import Foundation
import CoreLocation
import LoopSDK

typealias KnownLocationDataModel = [String: String]
let KnownLocationRepositoryAddedContentNotification = "ms.loop.trip.KnownLocationRepositoryAddedContentNotification"

public class KnownLocationRepository {
    static let sharedInstance = KnownLocationRepository()
    private init() {}
    private let concurrentKnownLocationQueue = dispatch_queue_create("ms.loop.trip.KnownLocationRepositoryQueue", DISPATCH_QUEUE_CONCURRENT)
    private var _locationsEntityIdMap: KnownLocationDataModel = [:]
    var locationsEntityIdMap: KnownLocationDataModel {
        var locationsEntityIdMapCopy: KnownLocationDataModel!
        dispatch_sync(concurrentKnownLocationQueue) {
            locationsEntityIdMapCopy = self._locationsEntityIdMap
        }
        return locationsEntityIdMapCopy
    }
    
    func loadData() {
        dispatch_barrier_async(self.concurrentKnownLocationQueue) {
            LoopSDK.syncManager.getProfileLocations {
                (loopLocations:[LoopLocation]) in
                
                self._locationsEntityIdMap.removeAll()
                
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
                        
                        self._locationsEntityIdMap[location.entityId] = knownLocationName
                    }
                }
                
                dispatch_async(GlobalMainQueue) {
                    NSNotificationCenter.defaultCenter().postNotificationName(KnownLocationRepositoryAddedContentNotification, object: nil)
                }
            }
        }
    }
}
