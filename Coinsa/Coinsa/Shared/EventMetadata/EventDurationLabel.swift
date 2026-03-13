//
//  EventDurationLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventDurationLabel: View {
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

private extension EventDurationLabel {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventDurationLabel(days: 7)
            EventDurationLabel(days: 14)
            EventDurationLabel(days: 31)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    EventDurationLabel.preview(colorScheme: .light)
}

#Preview("Dark") {
    EventDurationLabel.preview(colorScheme: .dark)
}
