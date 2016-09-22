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
