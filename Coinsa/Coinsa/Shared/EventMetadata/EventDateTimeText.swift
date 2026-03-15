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
    
    // MARK: - Body
    
    var body: some View {
        Text(dateTime, format: Date.displayFormatWithTime)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Previews

private extension EventDateTimeText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventDateTimeText(dateTime: .now)
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
