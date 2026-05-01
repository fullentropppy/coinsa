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
    var startDate: Date { get }
    
    /// Конечная дата диапазона.
    var endDate: Date { get }
    
    /// Текущий статус события.
    var status: EventStatus { get }
    
    /// Общее количество дней в диапазоне (включительно).
    var totalDays: Int { get }
    
    /// Количество прошедших дней от начала диапазона.
    var elapsedDays: Int { get }
    
    /// Количество оставшихся дней до конца диапазона.
    var remainingDays: Int { get }
    
    /// Закрытый интервал дат от `startDate` до `endDate`.
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
        totalDays()
    }
    
    /// Количество прошедших дней от начала диапазона.
    var elapsedDays: Int {
        elapsedDays()
    }
    
    /// Количество оставшихся дней до конца диапазона.
    var remainingDays: Int {
        remainingDays()
    }
    
    /// Закрытый интервал дат от `startDate` до `endDate`.
    var range: ClosedRange<Date> {
        startDate...endDate
    }
    
    // MARK: - Методы. Расчет с поддержкой календаря
    
    /// Определяет статус события относительно текущей даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Статус события.
    func status(using calendar: Calendar = .current) -> EventStatus {
        let today = Date().startOfDay(using: calendar)
        
        if today > endDate {
            return .completed
        } else if today.isBetween(startDate, and: endDate, using: calendar) {
            return .ongoing
        } else {
            return .upcoming
        }
    }
    
    /// Возвращает общее количество дней в диапазоне (включительно).
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество дней.
    func totalDays(using calendar: Calendar = .current) -> Int {
        endDate.days(from: startDate, using: calendar) + 1
    }
    
    /// Возвращает количество прошедших дней от начала диапазона до указанной даты.
    /// - Parameters:
    ///   - date: Дата, для которой вычисляется количество прошедших дней. По умолчанию - `.now`.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество прошедших дней (ограничено общим количеством дней).
    func elapsedDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        max(0, min(totalDays(using: calendar), date.days(from: startDate, using: calendar) + 1))
    }
    
    /// Возвращает количество оставшихся дней от указанной даты до конца диапазона.
    /// - Parameters:
    ///   - date: Дата, для которой вычисляется количество оставшихся дней. По умолчанию - `.now`.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество оставшихся дней (неотрицательное, ограниченное общим количеством дней).
    func remainingDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        min(totalDays(using: calendar), max(0, endDate.days(from: date, using: calendar)))
    }
}
