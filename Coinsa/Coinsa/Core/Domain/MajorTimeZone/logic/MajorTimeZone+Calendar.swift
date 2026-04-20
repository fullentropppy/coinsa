//
//  MajorTimeZone+Calendar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension MajorTimeZone {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
