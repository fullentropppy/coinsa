//
//  EventDateTimeText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import SwiftUI

struct EventDateTimeText: View {
    // MARK: - Stored Properties
    
    let dateTime: Date
    let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(dateTime: Date, style: ComponentStyle = .default) {
        self.dateTime = dateTime
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(dateTime, format: Date.displayFormatWithTime)
            .font(styleFont)
            .foregroundStyle(styleColor)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .default:
            return .body
        case .primary:
            return .headline
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var styleColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension EventDateTimeText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        
        return VStack(spacing: 20) {
            EventDateTimeText(dateTime: now, style: .default)
            EventDateTimeText(dateTime: now, style: .primary)
            EventDateTimeText(dateTime: now, style: .secondary)
            EventDateTimeText(dateTime: now, style: .tertiary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventDateTimeText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventDateTimeText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
