//
//  TimeZone+Calendar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.04.2026.
//

import Foundation

/// Создание календаря для конкретной временной зоны.
extension TimeZone {
    /// Григорианский календарь для временной зоны.
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = self
        return calendar
    }
}
