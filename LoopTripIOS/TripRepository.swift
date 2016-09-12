//
//  TripsModel.swift
//  Loop Trips Sample
//
//  Created by Xuwen Cao on 6/3/16.
//  Copyright © 2016 Microsoft. All rights reserved.
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

typealias TripDataModel = [(isSampleData: Bool, data:LoopTrip?)]
let TripRepositoryAddedContentNotification = "ms.loop.trip.TripRepositoryAddedContentNotification"

public class TripRepository {
    static let sharedInstance = TripRepository()
    private init() {}
    private let concurrentTripQueue = dispatch_queue_create("ms.loop.trip.TripRepositoryQueue", DISPATCH_QUEUE_CONCURRENT)
    let tripDispatchGroup = dispatch_group_create()
    private var _tableData: TripDataModel = []
    var tableData: TripDataModel {
        var tableDataCopy: TripDataModel!
        dispatch_sync(concurrentTripQueue) {
            tableDataCopy = self._tableData
        }
        return tableDataCopy
    }
    
    func loadData(loadDataCompletion: () -> Void) {
        if let dispatchGroupTrip = dispatch_group_create() {
            dispatch_group_enter(dispatchGroupTrip)

            LoopSDK.syncManager.getTrips(20, callback: {
                (loopTrips:[LoopTrip]) in
                
                dispatch_barrier_sync(self.concurrentTripQueue) {
                    self._tableData.removeAll()
                }
                
                if loopTrips.isEmpty {
                    let sampleTrips = JSONUtils.loadSampleTripData("SampleTrips")
                    for trip in sampleTrips {
                        dispatch_barrier_sync(self.concurrentTripQueue) {
                            self._tableData.append((isSampleData: true, data: trip))
                        }
                    }
                } else {
                    NSLog("Loop SDK returned \(loopTrips.count) trips")
                    for trip in loopTrips {
                        dispatch_barrier_sync(self.concurrentTripQueue) {
                            self._tableData.append((isSampleData: false, data: trip))
                        }
                    }
                }
                
                dispatch_group_leave(dispatchGroupTrip)
            })
            
            dispatch_group_notify(dispatchGroupTrip, GlobalMainQueue) {
                loadDataCompletion()
            }
        }
    }

    func removeData(index: Int) {
        dispatch_barrier_sync(self.concurrentTripQueue) {
            self._tableData.removeAtIndex(index)
        }
    }
}
