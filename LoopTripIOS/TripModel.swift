//
//  TripsModel.swift
//  Loop-Trip

import Foundation
import CoreLocation
import LoopSDK

public class TripModel {
    static let sharedInstance = TripModel()
    private init() {}
    let tripDispatchGroup = dispatch_group_create()
    var sampleData = false
    var tableData:[(shouldShowMap: Bool, isSampleData: Bool, data:LoopTrip?)] = []
    
    public func loadData(loadDataCompletion: () -> Void) {
        LoopSDK.syncManager.getTrips(40) {
            (loopTrips:[LoopTrip]) in
            
            self.tableData.removeAll()
            
            if loopTrips.isEmpty {
                self.sampleData = true
                
                let sampleTrips = JSONUtils.loadSampleTripData("SampleTrips")
                for trip in sampleTrips {
                    self.tableData.append((shouldShowMap: true, isSampleData: true, data: trip))
                }
            } else {
                NSLog("Loop SDK returned \(loopTrips.count) trips")
                for trip in loopTrips {
                    self.tableData.append((shouldShowMap:true, isSampleData: false, data:trip))
                }
            }
            
            loadDataCompletion()
        }
    }
}
