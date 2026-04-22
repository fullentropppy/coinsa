//
//  DateLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.03.2026.
//

import SwiftUI

struct DateLabel: View {
    // MARK: - Свойства
    
    private let date1: Date
    private let date2: Date?
    private let calendar: Calendar
    private let font: Font
    private let color: Color
    
    private var labelText: String {
        if let date2 {
            DateDisplayFormatter.formatRange(startDate: date1, endDate: date2, using: calendar)
        } else {
            DateDisplayFormatter.format(date1, using: calendar)
        }
    }
    
    // MARK: - Инициализация
    
    init(_ date: Date, using calendar: Calendar = .current, font: Font = .body, color: Color = .primary) {
        self.date1 = date
        self.date2 = nil
        self.calendar = calendar
        self.font = font
        self.color = color
    }
    
    init(
        from startDate: Date,
        to endDate: Date,
        using calendar: Calendar = .current,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.date1 = startDate
        self.date2 = endDate
        self.calendar = calendar
        self.font = font
        self.color = color
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
    static func secondarySmall(_ date: Date, using calendar: Calendar = .current) -> some View {
        DateLabel(date, using: calendar, font: .footnote, color: .secondary)
    }
    
    static func secondarySmall(
        from startDate: Date,
        to endDate: Date,
        using calendar: Calendar = .current
    ) -> some View {
        DateLabel(from: startDate, to: endDate, using: calendar, font: .footnote, color: .secondary)
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
