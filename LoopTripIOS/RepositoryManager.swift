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
    
    func loadRepositoryDataAsync() {
        if let dispatchGroupRepositoryManager = dispatch_group_create() {
            dispatch_group_enter(dispatchGroupRepositoryManager)
            self.driveRepository.loadData({
                dispatch_group_leave(dispatchGroupRepositoryManager)
            })
            
            dispatch_group_enter(dispatchGroupRepositoryManager)
            self.tripRepository.loadData({
                dispatch_group_leave(dispatchGroupRepositoryManager)
            })
            
            dispatch_group_enter(dispatchGroupRepositoryManager)
            self.knownLocationRepository.loadData({
                dispatch_group_leave(dispatchGroupRepositoryManager)
            })
            
            dispatch_group_notify(dispatchGroupRepositoryManager, GlobalMainQueue) {
                NSLog("SENDING UPDATE NOTIFICATION")
                NSNotificationCenter.defaultCenter().postNotificationName(RepositoryManagerAddedContentNotification, object: nil)
            }
        }
    }
}
