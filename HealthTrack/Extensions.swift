//
//  Extensions.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 5/5/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import Foundation

let goalForTheDay = 1200
let  SERVER_PATH = "http://10.0.0.117:9000/"
//let  SERVER_PATH = "http://10.250.216.12:9000/"

extension DateFormatter {
    func stringFromDate(date : Date) -> String{
        
        self.dateFormat = "yyyy-MM-ddHH:mm:ss";
        self.timeZone = TimeZone(abbreviation : "UTC")
        let dateString = self.string(from: date)
        return dateString;
    }
    
    func stringFromDateWithCurrentTimeZone(date : Date) -> String {
        self.dateFormat = "YYYY-MM-DDTHH:mm:ss.sssZ";
        self.timeZone = TimeZone.current
        let dateString = self.string(from: date)
        return dateString;
    }
    
    func timeString(date : Date) -> String {
        self.timeZone = TimeZone.current
        self.dateFormat = "HH:mm.ss"
        return self.string(from: date)
    }
    
    func dateStringFromDateForCalorie(date: Date) -> String {
        self.dateFormat = "MM:DD:YYYY"
        return self.string(from:date)
    }
}

extension Date {
    func midNightDate() -> Date {
        let cal = Calendar(identifier: .gregorian)
        let newDate = cal.startOfDay(for: self)
        return newDate
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
