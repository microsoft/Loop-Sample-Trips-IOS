//
//  TripsModel.swift
//  LoopTrip

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
    
    func loadData() {
        LoopSDK.syncManager.getTrips(40) {
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
            
            NSNotificationCenter.defaultCenter().postNotificationName(TripRepositoryAddedContentNotification, object: nil)
        }
    }

    func removeData(index: Int) {
        dispatch_barrier_sync(self.concurrentTripQueue) {
            self._tableData.removeAtIndex(index)
        }
    }
}
