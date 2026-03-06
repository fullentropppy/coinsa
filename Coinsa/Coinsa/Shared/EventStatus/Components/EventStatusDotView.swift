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
        Image(systemName: status.iconName).foregroundStyle(status.color)
    }
}

// MARK: - Previews

#Preview("Light") {
    EventStatusDotView(status: .upcoming)
    EventStatusDotView(status: .ongoing)
    EventStatusDotView(status: .completed)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    EventStatusDotView(status: .upcoming)
    EventStatusDotView(status: .ongoing)
    EventStatusDotView(status: .completed)
        .preferredColorScheme(.dark)
}
