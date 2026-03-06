//
//  EventDurationView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventDurationView: View {
    // MARK: - Stored Properties
    
    let days: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "clock")
            Text(String(days))
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Previews

#Preview("Light") {
    EventDurationView(days: 7)
    EventDurationView(days: 14)
    EventDurationView(days: 31)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    EventDurationView(days: 7)
    EventDurationView(days: 14)
    EventDurationView(days: 31)
        .preferredColorScheme(.dark)
}
