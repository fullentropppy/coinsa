//
//  EventIntervalText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventIntervalText: View {
    // MARK: - Stored Properties
    
    let startDate: Date
    let endDate: Date
    
    // MARK: - Body
    
    var body: some View {
        Text(startDate..<endDate, format: Date.tripIntervalFormat)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Previews

private extension EventIntervalText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventIntervalText(startDate: .now, endDate: .now)
            EventIntervalText(startDate: .now, endDate: .now.addingTimeInterval(604800))
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventIntervalText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventIntervalText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
