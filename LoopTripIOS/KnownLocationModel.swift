//
//  KnownLocationsModel.swift
//  Loop-Trip

import Foundation
import CoreLocation
import LoopSDK

public class KnownLocationModel {
    static let sharedInstance = KnownLocationModel()
    private init() {}
    var sampleData = false
    var locationsEntityIdMap = [String: String]()
    
    public func loadData(loadDataCompletion: () -> Void) {
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            self.locationsEntityIdMap.removeAll()
            
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
                    
                    self.locationsEntityIdMap[location.entityId] = knownLocationName
                }
            }
            
            loadDataCompletion()
        }
    }
}
