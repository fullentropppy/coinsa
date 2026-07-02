//
//  Calendar+UTC.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Фиксированный UTC-календарь для хранения пользовательских календарных компонентов.
extension Calendar {
    static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .utc
        return calendar
    }
}
