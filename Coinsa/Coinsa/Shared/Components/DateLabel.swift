//
//  DateLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.03.2026.
//

import SwiftUI

struct DateLabel: View {
    // MARK: - Stored Properties
    
    private let date1: Date
    private let date2: Date?
    private let font: Font
    private let color: Color
    
    // MARK: - Computed Properties
    
    private var labelText: String {
        if let endDate = date2 {
            DateDisplayFormatter.formatRange(startDate: date1, endDate: endDate)
        } else {
            DateDisplayFormatter.format(date1)
        }
    }
    
    // MARK: - Initialization
    
    init(
        _ date: Date,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.init(date1: date, font: font, color: color)
    }
    
    init(
        from date1: Date,
        to date2: Date,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.init(date1: date1, date2: date2, font: font, color: color)
    }
    
    private init(
        date1: Date,
        date2: Date? = nil,
        font: Font = .body,
        color: Color = .primary
    ) {
        self.date1 = date1
        self.date2 = date2
        self.font = font
        self.color = color
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(labelText)
            .font(font)
            .foregroundStyle(color)
    }
}

// MARK: - Presets

extension DateLabel {
    static func secondarySmall(_ date: Date) -> some View {
        DateLabel(date, font: .footnote, color: .secondary)
    }
    
    static func secondarySmall(from date1: Date, to date2: Date) -> some View {
        DateLabel(from: date1, to: date2, font: .footnote, color: .secondary)
    }

}

// MARK: - Previews

private extension DateLabel {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.addingTimeInterval(604800)
        let yearAhead = now.addingTimeInterval(31536000)
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                DateLabel(now)
                DateLabel(yearAhead, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                DateLabel(from: now, to: weekAhead)
                DateLabel(from: now, to: yearAhead, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                DateLabel.secondarySmall(yearAhead)
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
