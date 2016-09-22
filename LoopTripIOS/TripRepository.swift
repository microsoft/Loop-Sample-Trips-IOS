//
//  TripsModel.swift
//  Trips App
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

typealias TripDataModel = [(isSample: Bool, data:LoopTrip?)]
let TripRepositoryAddedContentNotification = "ms.loop.trip.TripRepositoryAddedContentNotification"

public class TripRepository {
    static let sharedInstance: TripRepository = TripRepository()
    private init() {}
    let concurrentTripQueue = DispatchQueue(label: "ms.loop.trip.TripRepositoryQueue", attributes: .concurrent)
    private var _tableData: TripDataModel = []
    var tableData: TripDataModel {
        var tableDataCopy: TripDataModel!
        concurrentTripQueue.sync {
            tableDataCopy = self._tableData
        }
        return tableDataCopy
    }
    
    func loadData(loadDataCompletion: @escaping () -> Void) {
        let dispatchGroupTrip = DispatchGroup()
        dispatchGroupTrip.enter()

        LoopSDK.syncManager.getTrips(20, callback: {
            (loopTrips:[LoopTrip]) in
            
            self.concurrentTripQueue.sync(flags: .barrier) {
                self._tableData.removeAll()
            }
            
            if loopTrips.isEmpty {
                let sampleTrips = JSONUtils.loadSampleTripData(sampleName: "SampleTrips")
                for trip in sampleTrips {
                    self.concurrentTripQueue.sync(flags: .barrier) {
                        self._tableData.append((isSample: true, data: trip))
                    }
                }
            } else {
                NSLog("Loop SDK returned \(loopTrips.count) trips")
                for trip in loopTrips {
                    self.concurrentTripQueue.sync(flags: .barrier) {
                        self._tableData.append((isSample: false, data: trip))
                    }
                }
            }
            
            dispatchGroupTrip.leave()
        })
        
        dispatchGroupTrip.notify(queue: DispatchQueue.main, execute: {
            loadDataCompletion()
        })
    }

    func removeData(index: Int) {
        self.concurrentTripQueue.sync(flags: .barrier) {
            _ = self._tableData.remove(at: index)
        }
    }
}
