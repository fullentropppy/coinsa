//
//  MajorTimeZone+Date.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension MajorTimeZone {
    func createDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = self.timeZone
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components)
    }
}
