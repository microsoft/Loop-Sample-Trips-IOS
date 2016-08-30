//
//  DrivesModel.swift
//  Loop-Trip

import Foundation
import CoreLocation
import LoopSDK

public class DriveModel {
    static let sharedInstance = DriveModel()
    private init() {}
    var sampleData = false
    var tableData:[(shouldShowMap: Bool, isSampleData: Bool, data:LoopTrip?)] = []
    
    public func loadData(loadDataCompletion: () -> Void) {
        LoopSDK.syncManager.getDrives(40, callback: {
            (loopDrives:[LoopTrip]) in
            
            self.tableData.removeAll()

            if loopDrives.isEmpty {
                self.sampleData = true
                
                let sampleDrives = JSONUtils.loadSampleTripData("SampleDrives")
                sampleDrives.forEach { drive in
                    self.tableData.append((shouldShowMap: true, isSampleData: true, data: drive))
                }
            } else {
                loopDrives.forEach { drive in
                    self.tableData.append((shouldShowMap:true, isSampleData: false, data:drive))
                }
            }
            
            loadDataCompletion()
        })
    }
}
