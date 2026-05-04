//
//  Date+UTC.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.05.2026.
//

import Foundation

/// Работа с UTC датами на основе локального времени.
extension Date {
    // MARK: - Свойства. UTC даты по текущему календарю
    
    /// Дата в UTC с временем 12:00 на основании локальной даты.
    var utcNoon: Date {
        utcNoon()
    }
    
    // MARK: - Методы. UTC даты с поддержкой календаря
    
    /// Возвращает дату в UTC с временем 12:00 на основании локальной даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Дата в UTC с 12:00, соответствующая локальному дню.
    func utcNoon(using calendar: Calendar = .current) -> Date {
        utcDate(hour: 12, minute: 0, second: 0, using: calendar)
    }
    
    /// Возвращает дату в UTC с указанным временем на основе локальной даты.
    /// - Parameters:
    ///   - hour: Час (0-23).
    ///   - minute: Минута (0-59). По умолчанию `0`.
    ///   - second: Секунда (0-59). По умолчанию `0`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Дата в UTC, соответствующая локальному дню.
    func utcDate(
        hour: Int,
        minute: Int = 0,
        second: Int = 0,
        using calendar: Calendar = .current
    ) -> Date {
        let localComponents = calendar.dateComponents([.year, .month, .day], from: self)

        var utcComponents = DateComponents()
        utcComponents.timeZone = TimeZone(secondsFromGMT: 0)
        utcComponents.year = localComponents.year
        utcComponents.month = localComponents.month
        utcComponents.day = localComponents.day
        utcComponents.hour = hour
        utcComponents.minute = minute
        utcComponents.second = second
        utcComponents.nanosecond = 0
        
        var utcCalendar = Calendar(identifier: calendar.identifier)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        return utcCalendar.date(from: utcComponents) ?? self
    }
}
