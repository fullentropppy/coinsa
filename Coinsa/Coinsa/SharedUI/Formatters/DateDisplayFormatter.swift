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
        if date.isTomorrow(using: calendar) {
            String(localized: .tomorrow)
        } else if date.isToday(using: calendar) {
            String(localized: .today)
        } else if date.isYesterday(using: calendar) {
            String(localized: .yesterday)
        } else {
            format(date, showsTime: showsTime, using: calendar)
        }
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
        let dateTemplate: String
        if showsWeekday {
            dateTemplate = Date().isSameYear(as: date) ? "EEEEdMMMM" : "EEEEdMMMMy"
        } else {
            dateTemplate = Date().isSameYear(as: date) ? "dMMMM" : "dMMMMy"
        }
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        
        return formatter.string(from: date)
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
        let dateTemplate = startDate.isSameYear(as: endDate, using: calendar)
        && Date().isSameYear(as: startDate, using: calendar) ? "dMMMM" : "dMy"
        
        let formatter = DateIntervalFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateTemplate = templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        
        return formatter.string(from: startDate, to: endDate)
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
}
