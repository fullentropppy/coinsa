//
//  IntervalText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct IntervalText: View {
    // MARK: - Stored Properties
    
    let startDate: Date
    let endDate: Date
    let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(startDate: Date, endDate: Date, style: ComponentStyle = .default) {
        self.startDate = startDate
        self.endDate = endDate
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(startDate..<endDate, format: Date.intervalFormat)
            .font(styleFont)
            .foregroundStyle(styleColor)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .primary:
            return .headline
        case .default, .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var styleColor: Color {
        switch style {
        case .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension IntervalText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.addingTimeInterval(604800)
        
        return VStack(alignment: .leading, spacing: 20) {
            IntervalText(startDate: now, endDate: now, style: .default)
            IntervalText(startDate: now, endDate: weekAhead, style: .default)
            IntervalText(startDate: now, endDate: now, style: .primary)
            IntervalText(startDate: now, endDate: weekAhead, style: .primary)
            IntervalText(startDate: now, endDate: now, style: .secondary)
            IntervalText(startDate: now, endDate: weekAhead, style: .secondary)
            IntervalText(startDate: now, endDate: now, style: .tertiary)
            IntervalText(startDate: now, endDate: weekAhead, style: .tertiary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    IntervalText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    IntervalText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
