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
    private let driveRepositoryDispatchGroup = dispatch_group_create()
    private var _tableData: DriveDataModel = []
    var tableData: DriveDataModel {
        var tableDataCopy: DriveDataModel!
        dispatch_sync(concurrentDriveQueue) {
            tableDataCopy = self._tableData
        }
        return tableDataCopy
    }
    
    func loadData(loadDataCompletion: () -> Void) {
        if let dispatchGroupDrive = dispatch_group_create() {
            dispatch_group_enter(dispatchGroupDrive)
            
            LoopSDK.syncManager.getDrives(20, callback: {
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
                
                dispatch_group_leave(dispatchGroupDrive)
            })
            
            dispatch_group_notify(dispatchGroupDrive, GlobalMainQueue) {
                loadDataCompletion()
            }
        }
    }
    
    func removeData(index: Int) {
        dispatch_barrier_sync(self.concurrentDriveQueue) {
            self._tableData.removeAtIndex(index)
        }
    }
}
