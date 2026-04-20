//
//  Calendar+MajorTimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension Calendar {
    static func withMajorTimeZone(_ majorTimeZone: MajorTimeZone) -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = majorTimeZone.timeZone
        return calendar
    }
}
