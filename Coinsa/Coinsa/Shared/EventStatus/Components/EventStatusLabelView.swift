//
//  EventStatusLabelView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

struct EventStatusLabelView: View {
    // MARK: - Stored Properties

    var status: EventStatus

    // MARK: - Body
    
    var body: some View {
        Text(status.localizedKey)
            .font(.caption).foregroundStyle(status.color)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(status.color, lineWidth: 2)
            )
    }
}

// MARK: - Previews

private extension EventStatusLabelView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventStatusLabelView(status: .upcoming)
            EventStatusLabelView(status: .ongoing)
            EventStatusLabelView(status: .completed)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventStatusLabelView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventStatusLabelView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
