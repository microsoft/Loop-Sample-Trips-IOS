//
//  Date.swift
//  Date utilities
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
import UIKit

extension Date {
    public func relativeDayAndTime() -> String {
        let localDate = Date(timeInterval: TimeInterval(TimeZone.ReferenceType.system.secondsFromGMT()), since: self)
        
        var startDay = ""
        guard let dayDiff = Calendar.current.dateComponents([.day], from: localDate, to: Date()).day else {
            return "Unknown".localized
        }
        
        if (dayDiff == 0) {
            startDay = "Today".localized
        }
        else if (dayDiff == 1) {
            startDay = "Yesterday".localized
        }
        
        if (startDay == "") {
            let startDayFormatter = DateFormatter()
            startDayFormatter.dateFormat = "MM/dd"
            startDayFormatter.timeZone = TimeZone.ReferenceType.local
            startDay = startDayFormatter.string(from: self)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.ReferenceType.local
        let startTime = timeFormatter.string(from: self)
        
        return startDay + " " + startTime
    }

    public func relativeDayAndStartEndTime(endDate: Date) -> String {
        let dayOfWeek: [String] = ["Sunday".localized,
                                        "Monday".localized,
                                        "Tuesday".localized,
                                        "Wednesday".localized,
                                        "Thursday".localized,
                                        "Friday".localized,
                                        "Saturday".localized]
        let localDate = Date(timeInterval: TimeInterval(TimeZone.ReferenceType.system.secondsFromGMT()), since: self)
        
        var startDay = ""
        guard let dayDiff = Calendar.current.dateComponents([.day], from: localDate, to: Date()).day else {
            return "Unkonwn".localized
        }
        
        guard let weekday = Calendar.current.dateComponents([.weekday], from: endDate).weekday else {
            return "Unknown".localized
        }
        
        if (dayDiff == 0) {
            startDay = "Today".localized
        }
        else if (dayDiff == 1) {
            startDay = "Yesterday".localized
        }
        else if (dayDiff < 7) {
            startDay = dayOfWeek[weekday - 1]
        }

        if (startDay == "") {
            let startDayFormatter = DateFormatter()
            startDayFormatter.dateFormat = "MM/dd"
            startDayFormatter.timeZone = TimeZone.ReferenceType.local
            startDay = startDayFormatter.string(from: self)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.ReferenceType.local
        let startTime = timeFormatter.string(from: self)
        let endTime = timeFormatter.string(from: endDate)
        
        return startDay + " " + startTime + " - " + endTime
    }
    
    func offsetFrom(endDate: Date) -> String {
        let difference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: endDate, to: self)
        
        var durationText = ""
        if (difference.second! > 0) {
            durationText = String(format: "00m %02ds", difference.second!)
        }
        
        if (difference.minute! > 0) {
            durationText = String(format: "%dm ", difference.minute!) + String(format: "%02ds", difference.second!)
        }
        
        if (difference.hour! > 0) {
            durationText = String(format: "%02dh ", difference.hour!) + durationText
        }
        
        if (difference.day! > 0) {
            durationText = String(format: "%02dd ", difference.day!) + durationText
        }
        
        return durationText
    }
}
