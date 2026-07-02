//
//  Date+CivilDateTimeStorage.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Кодирование пользовательской даты и времени для хранения.
extension Date {
    // MARK: - Свойства
    
    /// Дата и время без часового пояса, сохраненные в UTC-календаре.
    var storedCivilDateTime: Date {
        storedCivilDateTime()
    }
    
    // MARK: - Методы
    
    /// Возвращает дату и время без часового пояса в формате хранения.
    /// - Parameter calendar: Календарь, из которого считываются компоненты. По умолчанию `.current`.
    /// - Returns: Дата, сохраненная в UTC-календаре с теми же `year/month/day/hour/minute/second`.
    func storedCivilDateTime(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self
        )
        
        var utcComponents = DateComponents()
        utcComponents.timeZone = .utc
        utcComponents.year = components.year
        utcComponents.month = components.month
        utcComponents.day = components.day
        utcComponents.hour = components.hour
        utcComponents.minute = components.minute
        utcComponents.second = components.second
        utcComponents.nanosecond = 0
        
        return Calendar.utc.date(from: utcComponents) ?? self
    }
    
    /// Возвращает фактический момент времени из пользовательских компонентов даты и времени.
    /// - Parameter timeZone: Часовой пояс, в котором интерпретируются компоненты. По умолчанию `.current`.
    /// - Returns: Абсолютная дата для хранения как реального момента времени.
    func actualDateFromStoredCivilDateTime(using timeZone: TimeZone = .current) -> Date {
        let components = Calendar.utc.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self
        )
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        var actualComponents = DateComponents()
        actualComponents.timeZone = timeZone
        actualComponents.year = components.year
        actualComponents.month = components.month
        actualComponents.day = components.day
        actualComponents.hour = components.hour
        actualComponents.minute = components.minute
        actualComponents.second = components.second
        actualComponents.nanosecond = 0
        
        return calendar.date(from: actualComponents) ?? self
    }
}
