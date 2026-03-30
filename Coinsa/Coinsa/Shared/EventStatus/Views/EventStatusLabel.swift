//
//  EventStatusLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

struct EventStatusLabel: View {
    // MARK: - Stored Properties

    private var status: EventStatus

    // MARK: - Initialization
    
    init(_ status: EventStatus) {
        self.status = status
    }
    
    // MARK: - Body
    
    var body: some View {
        BadgeView(fillColor: status.color, title: status.localizedKey)
    }
}

// MARK: - Previews

private extension EventStatusLabel {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventStatusLabel(.upcoming)
            EventStatusLabel(.ongoing)
            EventStatusLabel(.completed)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventStatusLabel.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventStatusLabel.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
