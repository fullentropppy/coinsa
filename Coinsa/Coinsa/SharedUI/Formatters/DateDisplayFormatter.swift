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
    
    /// Форматирует год из даты в виде строки.
    /// - Parameter date: Дата, из которой извлекается год.
    /// - Returns: Строка с годом (например, "2026").
    static func formatYear(_ date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return String(year)
    }
    
    /// Форматирует год из числового значения в виде строки.
    /// - Parameter year: Числовое значение года.
    /// - Returns: Строка с годом (например, "2026").
    static func formatYear(_ year: Int) -> String {
        String(year)
    }
    
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
    
    /// Форматирует дату и время в относительном представлении.
    /// - Parameters:
    ///   - date: Форматируемая дата и время в гражданском формате.
    ///   - showsTime: Флаг отображения времени. По умолчанию `true`.
    /// - Returns: Локализованная строка.
    static func formatRelative(
        _ date: CivilDateTime,
        showsTime: Bool = true
    ) -> String {
        formatRelative(date.storedDate, showsTime: showsTime, using: .utc)
    }
    
    /// Форматирует дату в относительном представлении без времени.
    /// - Parameter date: Форматируемая дата в упрощенном формате.
    /// - Returns: Локализованная строка.
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
            dateTemplate = referenceDate.isSameYear(as: date, using: calendar) ? "dMMMM" : "dMMy"
        }
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        
        return formatter.string(from: date)
    }
    
    /// Форматирует дату и время в стандартном представлении.
    /// - Parameters:
    ///   - date: Форматируемая дата и время в гражданском формате.
    ///   - showsTime: Флаг отображения времени. По умолчанию `true`.
    ///   - showsWeekday: Показывать день недели. По умолчанию `false`.
    /// - Returns: Локализованная строка.
    static func format(
        _ date: CivilDateTime,
        showsTime: Bool = true,
        showsWeekday: Bool = false
    ) -> String {
        format(date.storedDate, showsTime: showsTime, showsWeekday: showsWeekday, using: .utc)
    }
    
    /// Форматирует дату в стандартном представлении без времени.
    /// - Parameters:
    ///   - date: Форматируемая дата в упрощенном формате.
    ///   - showsWeekday: Показывать день недели. По умолчанию `false`.
    /// - Returns: Локализованная строка.
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
    
    /// Форматирует диапазон дат в упрощенном формате без времени.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    /// - Returns: Локализованная строка с диапазоном дат.
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
    
    /// Возвращает опорную дату для вычислений относительно текущего момента.
    /// - Parameter calendar: Календарь для определения текущей даты.
    /// - Returns: Текущая дата в указанном календаре.
    private static func referenceDate(using calendar: Calendar) -> Date {
        calendar.timeZone == .utc ? CivilDateTime.now.storedDate : Date()
    }
}
