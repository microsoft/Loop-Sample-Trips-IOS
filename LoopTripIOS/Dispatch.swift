//
//  Dispatch.swift
//  LoopTrip
//

import Foundation

let DriveModelAddedContentNotification = "ms.loop.trip.DriveModelAddedContentNotification"
let TripModelAddedContentNotification = "ms.loop.trip.TripModelAddedContentNotification"
let KnownLocationModelAddedContentNotification = "ms.loop.trip.KnownLocationModelAddedContentNotification"

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}
