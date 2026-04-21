//
//  TimeZone+Calendar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.04.2026.
//

import Foundation

extension TimeZone {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = self
        return calendar
    }
}
