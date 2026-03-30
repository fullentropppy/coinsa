//
//  EventStatusImage.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventStatusImage: View {
    // MARK: - Stored Properties

    private var status: EventStatus

    // MARK: - Initialization
    
    init(_ status: EventStatus) {
        self.status = status
    }
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: "circle.fill")
            .foregroundStyle(status.color)
            .imageScale(.small)
    }
}

// MARK: - Previews

private extension EventStatusImage {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            EventStatusImage(.upcoming)
            EventStatusImage(.ongoing)
            EventStatusImage(.completed)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    EventStatusImage.preview(colorScheme: .light)
}

#Preview("Dark") {
    EventStatusImage.preview(colorScheme: .dark)
}
