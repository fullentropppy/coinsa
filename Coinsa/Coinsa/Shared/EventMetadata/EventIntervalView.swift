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

#Preview("Light - RU") {
    EventIntervalView(startDate: .now, endDate: .now.addingTimeInterval(604800))
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    EventIntervalView(startDate: .now, endDate: .now.addingTimeInterval(604800))
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
