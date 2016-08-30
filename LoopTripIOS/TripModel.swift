//
//  TripsModel.swift
//  Loop-Trip

import Foundation
import CoreLocation
import LoopSDK

public class TripModel {
    static let sharedInstance = TripModel()
    private init() {}
    var sampleData = false
    var tableData:[(shouldShowMap: Bool, isSampleData: Bool, data:LoopTrip?)] = []
    
    public func loadData(loadDataCompletion: () -> Void) {
        LoopSDK.syncManager.getTrips(40, callback: {
            (loopTrips:[LoopTrip]) in
            
            self.tableData.removeAll()
            
            if loopTrips.isEmpty {
                self.sampleData = true
                
                let sampleTrips = JSONUtils.loadSampleTripData("SampleTrips")
                sampleTrips.forEach { trip in
                    self.tableData.append((shouldShowMap: true, isSampleData: true, data: trip))
                }
            } else {
                loopTrips.forEach { trip in
                    self.tableData.append((shouldShowMap:true, isSampleData: false, data:trip))
                }
            }
            
            loadDataCompletion()
        })
    }
}
