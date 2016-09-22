//
//  Date.swift
//  Date utilities
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
