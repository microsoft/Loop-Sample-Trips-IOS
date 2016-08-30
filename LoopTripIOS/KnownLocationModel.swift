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
    var tableData:[(text: String, data:LoopLocation?)] = []
    
    public func loadData(loadDataCompletion: () -> Void) {
        LoopSDK.syncManager.getProfileLocations {
            (loopLocations:[LoopLocation]) in
            
            self.tableData.removeAll()
            
            if !loopLocations.isEmpty {
                loopLocations.forEach { location in
                    self.tableData.append(("", data:location))
                }
            }
            
            loadDataCompletion()
        }
    }
}
