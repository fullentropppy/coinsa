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

private extension EventDurationView {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventDurationView(days: 7)
            EventDurationView(days: 14)
            EventDurationView(days: 31)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    EventDurationView.preview(colorScheme: .light)
}

#Preview("Dark") {
    EventDurationView.preview(colorScheme: .dark)
}
