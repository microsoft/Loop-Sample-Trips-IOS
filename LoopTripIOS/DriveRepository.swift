//
//  DrivesModel.swift
//  LoopTrip

import Foundation
import CoreLocation
import LoopSDK

typealias DriveDataModel = [(isSampleData: Bool, data:LoopTrip?)]
let DriveRepositoryAddedContentNotification = "ms.loop.trip.DriveRepositoryAddedContentNotification"

public class DriveRepository {
    static let sharedInstance = DriveRepository()
    private init() {}
    private let concurrentDriveQueue = dispatch_queue_create("ms.loop.trip.DriveRepositoryQueue", DISPATCH_QUEUE_CONCURRENT)
    private var _tableData: DriveDataModel = []
    var tableData: DriveDataModel {
        var tableDataCopy: DriveDataModel!
        dispatch_sync(concurrentDriveQueue) {
            tableDataCopy = self._tableData
        }
        return tableDataCopy
    }
    
    func loadData() {
        dispatch_barrier_async(self.concurrentDriveQueue) {
            LoopSDK.syncManager.getDrives(40, callback: {
                (loopDrives:[LoopTrip]) in
                
                self._tableData.removeAll()
                
                if loopDrives.isEmpty {
                    let sampleDrives = JSONUtils.loadSampleTripData("SampleDrives")
                    for drive in sampleDrives {
                        self._tableData.append((isSampleData: true, data: drive))
                    }
                } else {
                    NSLog("Loop SDK returned \(loopDrives.count) drives")
                    for drive in loopDrives {
                        self._tableData.append((isSampleData: false, data:drive))
                    }
                }
                
                dispatch_async(GlobalMainQueue) {
                    NSNotificationCenter.defaultCenter().postNotificationName(DriveRepositoryAddedContentNotification, object: nil)
                }
            })
        }
    }
    
    func removeData(index: Int) {
        dispatch_barrier_sync(self.concurrentDriveQueue) {
            self._tableData.removeAtIndex(index)
        }
    }
}
