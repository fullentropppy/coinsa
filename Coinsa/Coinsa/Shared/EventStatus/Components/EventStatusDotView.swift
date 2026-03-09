//
//  EventStatusDotView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventStatusDotView: View {
    // MARK: - Stored Properties

    var status: EventStatus

    // MARK: - Body
    
    var body: some View {
        Image(systemName: "circle.fill").foregroundStyle(status.color)
    }
}

// MARK: - Previews

private extension EventStatusDotView {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventStatusDotView(status: .upcoming)
            EventStatusDotView(status: .ongoing)
            EventStatusDotView(status: .completed)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    EventStatusDotView.preview(colorScheme: .light)
}

#Preview("Dark") {
    EventStatusDotView.preview(colorScheme: .dark)
}
