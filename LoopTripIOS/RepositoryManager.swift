//
//  RepositoryManager.swift
//  LoopTrip
//

import Foundation
import CoreLocation
import LoopSDK

let RepositoryManagerAddedContentNotification = "ms.loop.trip.RepositoryManagerAddedContentNotification"

public class RepositoryManager {
    static let sharedInstance = RepositoryManager()
    private init() {}
    private let concurrentRepositoryManagerQueue = dispatch_queue_create("ms.loop.trip.RepositoryManagerQueue", DISPATCH_QUEUE_CONCURRENT)

    let driveRepository = DriveRepository.sharedInstance
    let tripRepository = TripRepository.sharedInstance
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    
    func loadRepositoryData() {
        dispatch_barrier_async(self.concurrentRepositoryManagerQueue) {
            self.driveRepository.loadData()
            self.tripRepository.loadData()
            self.knownLocationRepository.loadData()
            
            dispatch_async(GlobalMainQueue) {
                NSNotificationCenter.defaultCenter().postNotificationName(RepositoryManagerAddedContentNotification, object: nil)
            }
        }
    }
}
