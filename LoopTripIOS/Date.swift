//
//  Date.swift
//  Date utilities
//  Loop Trips Sample
//

import Foundation
import UIKit

extension NSDate {
    public func relativeDayAndTime() -> String {
        let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: self)
        
        var startDay = ""
        let dayDiff = NSCalendar.currentCalendar().components([.Day], fromDate: NSDate(), toDate: localDate, options: [])
        if (dayDiff == 0) {
            startDay = "Today"
        }
        else if (dayDiff == 1) {
            startDay = "Yesterday"
        }
        
        if (startDay == "") {
            let startDayFormatter = NSDateFormatter()
            startDayFormatter.dateFormat = "MM/dd"
            startDayFormatter.timeZone = NSTimeZone.localTimeZone()
            startDay = startDayFormatter.stringFromDate(self)
        }
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = NSTimeZone.localTimeZone()
        let startTime = timeFormatter.stringFromDate(self)
        
        return startDay + " " + startTime
    }

    public func relativeDayAndStartEndTime(endDate: NSDate) -> String {
        let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: self)
        
        var startDay = ""
        let dayDiff = NSCalendar.currentCalendar().components([.Day], fromDate: NSDate(), toDate: localDate, options: [])
        if (dayDiff == 0) {
            startDay = "Today"
        }
        else if (dayDiff == 1) {
            startDay = "Yesterday"
        }

        if (startDay == "") {
            let startDayFormatter = NSDateFormatter()
            startDayFormatter.dateFormat = "MM/dd"
            startDayFormatter.timeZone = NSTimeZone.localTimeZone()
            startDay = startDayFormatter.stringFromDate(self)
        }
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = NSTimeZone.localTimeZone()
        let startTime = timeFormatter.stringFromDate(self)
        let endTime = timeFormatter.stringFromDate(endDate)
        
        return startDay + " " + startTime + " - " + endTime
    }
    
    func offsetFrom(endDate: NSDate) -> String {
        let difference = NSCalendar.currentCalendar().components([.Day, .Hour, .Minute, .Second], fromDate: endDate, toDate: self, options: [])
        
        var durationText = ""
        if (difference.second > 0) {
            durationText = String(format: "%02d", difference.second)
        }
        
        if (difference.minute > 0) {
            durationText = String(format: "%02d", difference.minute) + ":" + durationText
        }
        
        if (difference.hour > 0) {
            durationText = String(format: "%02d", difference.hour) + ":" + durationText
        }
        
        if (difference.day > 0) {
            durationText = String(format: "%02d", difference.day) + ":" + durationText
        }
        
        return durationText
    }
}
