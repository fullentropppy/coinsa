//
//  EventStatusView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

struct EventStatusView: View {
    // MARK: - Stored Properties

    var status: EventStatus

    var body: some View {
        Text(status.localized)
            .font(.caption).foregroundStyle(status.color)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 100).stroke(status.color, lineWidth: 2))
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    EventStatusView(status: .upcoming)
    EventStatusView(status: .ongoing)
    EventStatusView(status: .completed)
        .preferredColorScheme(.light)
}

#Preview("Dark - RU") {
    EventStatusView(status: .upcoming)
    EventStatusView(status: .ongoing)
    EventStatusView(status: .completed)
        .preferredColorScheme(.dark)
}
