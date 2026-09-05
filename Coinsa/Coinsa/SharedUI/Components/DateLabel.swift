//
//  DateLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.03.2026.
//

import SwiftUI

/// Метка для отображения даты или диапазона дат.
struct DateLabel: View {
    // MARK: - Свойства
    
    private let date1: Date
    private let date2: Date?
    private let showsTime: Bool
    private let calendar: Calendar
    private let font: Font
    private let color: Color
    
    private var labelText: String {
        if let date2 {
            DateDisplayFormatter.formatRange(startDate: date1, endDate: date2, showsTime: showsTime, using: calendar)
        } else {
            DateDisplayFormatter.format(date1, showsTime: showsTime, using: calendar)
        }
    }
    
    // MARK: - Инициализация
    
    /// Создает метку для одной даты.
    /// - Parameters:
    ///   - date: Отображаемая дата.
    ///   - showsTime: Отображать время. По умолчанию `true`.
    ///   - calendar: Календарь для форматирования. По умолчанию `.current`.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.primary`.
    init(
        _ date: Date,
        withTime showsTime: Bool = true,
        using calendar: Calendar = .current,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.date1 = date
        self.date2 = nil
        self.showsTime = showsTime
        self.calendar = calendar
        self.font = font
        self.color = color
    }
    
    /// Создает метку для одной календарерй даты без привязки к часовому поясу.
    /// - Parameters:
    ///   - date: Отображаемая дата.
    ///   - showsTime: Отображать время. По умолчанию `true`.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.primary`.
    init(
        _ date: CivilDateTime,
        withTime showsTime: Bool = true,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.init(date.storedDate, withTime: showsTime, using: .utc, font: font, color: color)
    }
    
    /// Создает метку для диапазона дат.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - showsTime: Отображать время. По умолчанию `false`.
    ///   - calendar: Календарь для форматирования. По умолчанию `.current`.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.primary`.
    init(
        from startDate: Date,
        to endDate: Date,
        withTime showsTime: Bool = false,
        using calendar: Calendar = .current,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.date1 = startDate
        self.date2 = endDate
        self.showsTime = showsTime
        self.calendar = calendar
        self.font = font
        self.color = color
    }
    
    /// Создает метку для диапазона календарных дат без привязки к часовому поясу.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - showsTime: Отображать время. По умолчанию `false`.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста. По умолчанию `.primary`.
    init(
        from startDate: PlainDate,
        to endDate: PlainDate,
        withTime showsTime: Bool = false,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.init(from: startDate.storedDate, to: endDate.storedDate, using: .utc, font: font, color: color)
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Text(labelText)
            .font(font)
            .foregroundStyle(color)
    }
}

// MARK: - Предопределенные варианты

extension DateLabel {
    /// Вторичная компактная метка для одной даты.
    /// - Parameters:
    ///   - date: Отображаемая дата.
    ///   - showsTime: Отображать время. По умолчанию `true`.
    ///   - calendar: Календарь для форматирования. По умолчанию `.current`.
    /// - Returns: Метка с мелким шрифтом и вторичным цветом.
    static func secondarySmall(
        _ date: Date,
        withTime showsTime: Bool = true,
        using calendar: Calendar = .current
    ) -> some View {
        DateLabel(date, withTime: showsTime, using: calendar, font: .footnote, color: .secondary)
    }
    
    /// Вторичная компактная метка для одной календарной даты без привязки к часовому поясу.
    /// - Parameters:
    ///   - date: Отображаемая дата.
    ///   - showsTime: Отображать время. По умолчанию `true`.
    /// - Returns: Метка с мелким шрифтом и вторичным цветом.
    static func secondarySmall(
        _ date: CivilDateTime,
        withTime showsTime: Bool = true,
        using calendar: Calendar = .current
    ) -> some View {
        DateLabel(date, withTime: showsTime, font: .footnote, color: .secondary)
    }
    
    /// Вторичная компактная метка для диапазона дат.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - showsTime: Отображать время. По умолчанию `false`.
    ///   - calendar: Календарь для форматирования. По умолчанию `.current`.
    /// - Returns: Метка с мелким шрифтом и вторичным цветом.
    static func secondarySmall(
        from startDate: Date,
        to endDate: Date,
        withTime showsTime: Bool = false,
        using calendar: Calendar = .current
    ) -> some View {
        DateLabel(from: startDate, to: endDate, withTime: showsTime, using: calendar, font: .footnote, color: .secondary)
    }
    
    /// Вторичная компактная метка для диапазона календарных дат без привязки к часовому поясу.
    /// - Parameters:
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - showsTime: Отображать время. По умолчанию `false`.
    /// - Returns: Метка с мелким шрифтом и вторичным цветом.
    static func secondarySmall(
        from startDate: PlainDate,
        to endDate: PlainDate,
        withTime showsTime: Bool = false,
        using calendar: Calendar = .current
    ) -> some View {
        DateLabel(from: startDate, to: endDate, withTime: showsTime, font: .footnote, color: .secondary)
    }
}

// MARK: - Превью

private extension DateLabel {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.adding(weeks: 1)
        let yearAhead = now.adding(years: 1)
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                DateLabel(now)
                DateLabel(now, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                DateLabel(yearAhead)
                DateLabel(yearAhead, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                DateLabel(from: now, to: weekAhead)
                DateLabel(from: now, to: yearAhead, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                DateLabel.secondarySmall(now)
                DateLabel.secondarySmall(from: now, to: yearAhead)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    DateLabel.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    DateLabel.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
