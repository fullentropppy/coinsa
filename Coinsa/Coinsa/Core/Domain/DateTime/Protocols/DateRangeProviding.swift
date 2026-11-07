//
//  DateRangeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Протокол

/// Протокол для объектов, имеющих временной диапазон с начальной и конечной датой.
protocol DateRangeProviding {
    /// Начальная дата диапазона.
    var startPlainDate: PlainDate { get }
    
    /// Конечная дата диапазона.
    var endPlainDate: PlainDate { get }
    
    /// Текущий статус события.
    var status: EventStatus { get }
    
    /// Общее количество дней в диапазоне (включительно).
    var totalDays: Int { get }
    
    /// Количество прошедших дней от начала диапазона.
    var elapsedDays: Int { get }
    
    /// Количество оставшихся дней до конца диапазона.
    var remainingDays: Int { get }
    
    /// Закрытый интервал дат от начала дня `startDate` до конца дня `endDate`.
    var range: ClosedRange<Date> { get }
}

// MARK: - Стандартная реализация

extension DateRangeProviding {
    // MARK: - Свойства. Расчет по текущему календарю
    
    /// Текущий статус события.
    var status: EventStatus {
        status()
    }
    
    /// Общее количество дней в диапазоне (включительно).
    var totalDays: Int {
        endPlainDate.days(from: startPlainDate) + 1
    }
    
    /// Количество прошедших дней от начала диапазона.
    var elapsedDays: Int {
        elapsedDays()
    }
    
    /// Количество оставшихся дней до конца диапазона.
    var remainingDays: Int {
        remainingDays()
    }
    
    /// Закрытый интервал дат от начала дня `startPlainDate` до конца дня `endPlainDate`.
    var range: ClosedRange<Date> {
        range(using: .utc)
    }
    
    // MARK: - Методы. Расчет с поддержкой календаря
    
    /// Определяет статус события относительно текущей даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Статус события.
    func status(using calendar: Calendar = .utc) -> EventStatus {
        let today = PlainDate.today.startOfDay(using: calendar)
        let startDateStartOfDay = startPlainDate.startOfDay(using: calendar)
        let endDateEndOfDay = endPlainDate.endOfDay(using: calendar)
        
        if today > endDateEndOfDay {
            return .completed
        } else if today.isBetween(startDateStartOfDay, and: endDateEndOfDay) {
            return .ongoing
        } else {
            return .upcoming
        }
    }

    /// Возвращает количество прошедших дней от начала диапазона до указанной даты.
    /// - Parameters:
    ///   - date: Дата, для которой вычисляется количество прошедших дней. По умолчанию `.today`.
    /// - Returns: Количество прошедших дней (ограничено общим количеством дней).
    func elapsedDays(on date: PlainDate = .today) -> Int {
        max(0, min(totalDays, date.days(from: startPlainDate) + 1))
    }
    
    /// Возвращает количество оставшихся дней от указанной даты до конца диапазона.
    /// - Parameters:
    ///   - date: Дата, для которой вычисляется количество оставшихся дней. По умолчанию `.today`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Количество оставшихся дней (неотрицательное, ограниченное общим количеством дней).
    func remainingDays(on date: PlainDate = .today, using calendar: Calendar = .utc) -> Int {
        min(
            totalDays,
            max(0, endPlainDate.endOfDay.days(from: date.storedDate, using: .utc))
        )
    }
    
    /// Возвращает закрытый интервал дат от начала дня `startPlainDate` до конца дня `endPlainDate`.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Закрытый интервал дат.
    func range(using calendar: Calendar = .utc) -> ClosedRange<Date> {
        startPlainDate.startOfDay(using: calendar)...endPlainDate.endOfDay(using: calendar)
    }
}
