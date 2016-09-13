//
//  RepositoryManager.swift
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

let RepositoryManagerAddedContentNotification = "ms.loop.trip.RepositoryManagerAddedContentNotification"

public class RepositoryManager {
    static let sharedInstance = RepositoryManager()
    private init() {}

    let driveRepository = DriveRepository.sharedInstance
    let tripRepository = TripRepository.sharedInstance
    let knownLocationRepository = KnownLocationRepository.sharedInstance
    
    func loadRepositoryDataAsync(sendUpdateNotification: Bool) {
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
                if (sendUpdateNotification) {
                    NSLog("SENDING UPDATE NOTIFICATION")
                    NSNotificationCenter.defaultCenter().postNotificationName(RepositoryManagerAddedContentNotification, object: nil)
                }
            }
        }
    }
}
