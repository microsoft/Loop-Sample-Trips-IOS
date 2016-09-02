//
//  DrivesModel.swift
//  LoopTrip

import Foundation
import CoreLocation
import LoopSDK

typealias DriveDataModel = [(isSampleData: Bool, data:LoopTrip?)]
let DriveModelAddedContentNotification = "ms.loop.trip.DriveModelAddedContentNotification"

public class DriveModel {
    static let sharedInstance = DriveModel()
    private init() {}
    private let concurrentDriveQueue = dispatch_queue_create("ms.loop.trip.DriveModelQueue", DISPATCH_QUEUE_CONCURRENT)
    private var _tableData: DriveDataModel = []
    var tableData: DriveDataModel {
        var tableDataCopy: DriveDataModel!
        dispatch_sync(concurrentDriveQueue) {
            tableDataCopy = self._tableData
        }
        return tableDataCopy
    }
    
    func loadData() {
        LoopSDK.syncManager.getDrives(40, callback: {
            (loopDrives:[LoopTrip]) in
            
            dispatch_barrier_sync(self.concurrentDriveQueue) {
                self._tableData.removeAll()
            }

            if loopDrives.isEmpty {
                let sampleDrives = JSONUtils.loadSampleTripData("SampleDrives")
                for drive in sampleDrives {
                    dispatch_barrier_sync(self.concurrentDriveQueue) {
                        self._tableData.append((isSampleData: true, data: drive))
                    }
                }
            } else {
                NSLog("Loop SDK returned \(loopDrives.count) drives")
                for drive in loopDrives {
                    dispatch_barrier_sync(self.concurrentDriveQueue) {
                        self._tableData.append((isSampleData: false, data:drive))
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(DriveModelAddedContentNotification, object: nil)
        })
    }
    
    func removeData(index: Int) {
        dispatch_barrier_sync(self.concurrentDriveQueue) {
            self._tableData.removeAtIndex(index)
        }
    }
}
