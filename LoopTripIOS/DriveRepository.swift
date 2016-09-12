//
//  DrivesModel.swift
//  Loop Trips Sample
//
//  Copyright (c) Microsoft Corporation
//
//  All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the License); you may not 
//  use this file except in compliance with the License. You may obtain a copy 
//  of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS 
//  OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY 
//  IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE, 
//  MERCHANTABLITY OR NON-INFRINGEMENT.
//
//  See the Apache Version 2.0 License for specific language governing permissions 
//  and limitations under the License.
//

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
