//
//  EventIntervalView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventIntervalView: View {
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

private extension EventIntervalView {
    static func preview(locale: String, colorScheme: ColorScheme) -> some View {
        EventIntervalView(startDate: .now, endDate: .now.addingTimeInterval(604800))
            .environment(\.locale, Locale(identifier: locale))
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventIntervalView.preview(locale: "ru", colorScheme: .light)
}

#Preview("Dark - EN") {
    EventIntervalView.preview(locale: "en", colorScheme: .dark)
}
