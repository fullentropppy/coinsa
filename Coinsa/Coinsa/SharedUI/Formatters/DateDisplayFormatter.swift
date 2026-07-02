//
//  DateDisplayFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import Foundation

/// Форматтер для отображения дат в пользовательском интерфейсе.
struct DateDisplayFormatter {
    // MARK: - Публичные методы
    
    /// Форматирует дату с относительным представлением (вчера, сегодня, завтра или стандартный формат).
    /// - Parameters:
    ///   - date: Форматируемая дата.
    ///   - showsTime: Флаг отображения времени. По умолчанию `true`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Локализованная строка.
    static func formatRelative(
        _ date: Date,
        showsTime: Bool = true,
        using calendar: Calendar = .current
    ) -> String {        
        let referenceDate = referenceDate(using: calendar)
        
        if date.isSameDay(as: referenceDate.tomorrow(using: calendar), using: calendar) {
            return String(localized: .tomorrow)
        } else if date.isSameDay(as: referenceDate, using: calendar) {
            return String(localized: .today)
        } else if date.isSameDay(as: referenceDate.yesterday(using: calendar), using: calendar) {
            return String(localized: .yesterday)
        } else {
            return format(date, showsTime: showsTime, using: calendar)
        }
    }
    
    static func formatRelative(
        _ date: CivilDateTime,
        showsTime: Bool = true
    ) -> String {
        formatRelative(date.storedDate, showsTime: showsTime, using: .utc)
    }
    
    static func formatRelative(
        _ date: PlainDate
    ) -> String {
        formatRelative(date.storedDate, showsTime: false, using: .utc)
    }
    
    /// Форматирует дату в стандартном представлении.
    /// - Parameters:
    ///   - date: Форматируемая дата.
    ///   - showsTime: Флаг отображения времени. По умолчанию `true`.
    ///   - showsWeekday: Показывать день недели. По умолчанию `false`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Локализованная строка.
    static func format(
        _ date: Date,
        showsTime: Bool = true,
        showsWeekday: Bool = false,
        using calendar: Calendar = .current
    ) -> String {
        let referenceDate = referenceDate(using: calendar)
        let dateTemplate: String
        if showsWeekday {
            dateTemplate = referenceDate.isSameYear(as: date, using: calendar) ? "EEEEdMMMM" : "EEEEdMMMMy"
        } else {
            dateTemplate = referenceDate.isSameYear(as: date, using: calendar) ? "dMMMM" : "dMMMMy"
        }
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        
        return formatter.string(from: date)
    }
    
    static func format(
        _ date: CivilDateTime,
        showsTime: Bool = true,
        showsWeekday: Bool = false
    ) -> String {
        format(date.storedDate, showsTime: showsTime, showsWeekday: showsWeekday, using: .utc)
    }
    
    static func format(
        _ date: PlainDate,
        showsWeekday: Bool = false
    ) -> String {
        format(date.storedDate, showsTime: false, showsWeekday: showsWeekday, using: .utc)
    }

    /// Форматирует диапазон дат.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - showsTime: Флаг отображения времени. По умолчанию `false`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Локализованная строка с диапазоном дат.
    static func formatRange(
        startDate: Date,
        endDate: Date,
        showsTime: Bool = false,
        using calendar: Calendar = .current
    ) -> String {
        let referenceDate = referenceDate(using: calendar)
        let dateTemplate = startDate.isSameYear(as: endDate, using: calendar)
        && referenceDate.isSameYear(as: startDate, using: calendar) ? "dMMMM" : "dMy"
        
        let formatter = DateIntervalFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateTemplate = templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        
        return formatter.string(from: startDate, to: endDate)
    }
    
    static func formatRange(
        startDate: PlainDate,
        endDate: PlainDate
    ) -> String {
        formatRange(startDate: startDate.storedDate, endDate: endDate.storedDate, using: .utc)
    }

    // MARK: - Приватные методы

    /// Добавляет компонент времени к шаблону даты при необходимости.
    /// - Parameters:
    ///   - dateTemplate: Базовый шаблон даты.
    ///   - showsTime: Флаг отображения времени.
    /// - Returns: Итоговый шаблон для форматтера.
    private static func templateWithOptionalTime(dateTemplate: String, showsTime: Bool) -> String {
        showsTime ? "\(dateTemplate)jm" : dateTemplate
    }
    
    private static func referenceDate(using calendar: Calendar) -> Date {
        calendar.timeZone == .utc ? CivilDateTime.now.storedDate : Date()
    }
}
