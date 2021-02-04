//
//  DateExtension.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation

extension Date {
    
    init?(fromString: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: fromString) {
            self = date
        } else {
            return nil
        }
    }
    
    static func fromNews(_ str: String) -> Date? {
        // date and time is separated by the character T
        // not possible to use date formatter directly
        let dateStrings = str.split(separator: "T")
        if dateStrings.count == 2 {
            return Date(fromString: "\(dateStrings[0])\(dateStrings[1])", format: "yyyy-MM-ddHH:mm:ssZ")
        }
        return nil
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func isOnSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    // Returns value based on time passed since date
    // ex. 5 hrs ago, 2 days ago, 50 mins ago
    func toIntervalString() -> String {
        let interval = -self.timeIntervalSinceNow
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval/60)
            if minutes == 1 {
                return "1 min"
            } else {
                return "\(minutes) mins"
            }
        } else if interval < 86400 {
            let hours = Int(interval/3600)
            if hours == 1 {
                return "1 hr"
            } else {
                return "\(hours) hrs"
            }
        } else {
            let days = Int(interval/86400)
            if days == 1 {
                return "1 day"
            } else {
                return "\(days) days"
            }
        }
    }
    
    static func dateFormatForRange(_ range: String) -> String {
        switch range {
        case "1d", "5d":
            return "yyyy-MM-dd HH:mm"
        default:
            return "yyyy-MM-dd"
        }
    }
    
    var previousDay: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
}
