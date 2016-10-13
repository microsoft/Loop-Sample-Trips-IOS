//
//  TripsModel.swift
//  Trips App
//
//  Copyright (c) 2016 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    private var newTableData: TripDataModel = []
    
    func loadData(loadDataCompletion: @escaping () -> Void) {
        let dispatchGroupTrip = DispatchGroup()
        dispatchGroupTrip.enter()

        NSLog("Calling LoopSDK.syncManager.getTrips")

        LoopSDK.syncManager.getTrips(20, callback: {
            (loopTrips:[LoopTrip]) in
            
            NSLog("Returned from LoopSDK.syncManager.getTrips")

            self.newTableData.removeAll()
            
            if loopTrips.isEmpty {
                let sampleTrips = JSONUtils.loadSampleTripData(sampleName: "SampleTrips")
                for trip in sampleTrips {
                    self.newTableData.append((isSample: true, data: trip))
                }
            } else {
                NSLog("Loop SDK returned \(loopTrips.count) trips")
                for trip in loopTrips {
                    self.newTableData.append((isSample: false, data: trip))
                }
            }
            
            dispatchGroupTrip.leave()
        })
        
        dispatchGroupTrip.notify(queue: DispatchQueue.main, execute: {
            loadDataCompletion()
        })
    }
    
    func updateData() {
        self.concurrentTripQueue.sync {
            self._tableData.removeAll()
            self._tableData = self.newTableData
        }
    }
    
    func removeData(index: Int) {
        self.concurrentTripQueue.sync {
            _ = self._tableData.remove(at: index)
        }
    }

    func removeAllData() {
        self.concurrentTripQueue.sync {
            self._tableData.removeAll()
        }
    }
}
