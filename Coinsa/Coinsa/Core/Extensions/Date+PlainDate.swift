//
//  Date+PlainDate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Работа с календарными датами без времени и часового пояса.
extension Date {
    // MARK: - Свойства
    
    /// Дата без времени и часового пояса в формате хранения.
    var storedPlainDate: Date {
        storedPlainDate()
    }
    
    // MARK: - Методы
    
    /// Возвращает дату без времени и часового пояса.
    /// - Parameter calendar: Календарь, из которого считываются компоненты. По умолчанию `.current`.
    /// - Returns: Дата, сохраненная как UTC 00:00 с теми же `year/month/day`.
    func storedPlainDate(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        
        var utcComponents = DateComponents()
        utcComponents.timeZone = .utc
        utcComponents.year = components.year
        utcComponents.month = components.month
        utcComponents.day = components.day
        utcComponents.hour = 0
        utcComponents.minute = 0
        utcComponents.second = 0
        utcComponents.nanosecond = 0
        
        return Calendar.utc.date(from: utcComponents) ?? self
    }
}
