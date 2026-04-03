//
//  EventStatusBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventStatusBadge: View {
    // MARK: - Stored Properties

    private var status: EventStatus

    // MARK: - Initialization
    
    init(_ status: EventStatus) {
        self.status = status
    }
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: "circle.fill")
            .imageScale(.small)
            .foregroundStyle(status.badgeColor)
    }
}

// MARK: - Previews

private extension EventStatusBadge {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventStatusBadge(.upcoming)
            EventStatusBadge(.ongoing)
            EventStatusBadge(.completed)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    EventStatusBadge.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    EventStatusBadge.makePreview(colorScheme: .dark)
}
