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
        Text(status.localizedDisplayName)
            .font(.caption).foregroundStyle(status.color)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(status.color, lineWidth: 2)
            )
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    EventStatusLabelView(status: .upcoming)
    EventStatusLabelView(status: .ongoing)
    EventStatusLabelView(status: .completed)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - RU") {
    EventStatusLabelView(status: .upcoming)
    EventStatusLabelView(status: .ongoing)
    EventStatusLabelView(status: .completed)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
