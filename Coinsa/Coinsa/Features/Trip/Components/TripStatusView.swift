//
//  TripStatusView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import SwiftUI

struct TripStatusView: View {
    // MARK: - Stored properties
    
    var status: TripStatus
    
    var body: some View {
        Text(status.localized)
            .font(.caption).foregroundStyle(status.color)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 100).stroke(status.color, lineWidth: 2))
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripStatusView(status: .upcoming)
    TripStatusView(status: .ongoing)
    TripStatusView(status: .completed)
        .preferredColorScheme(.light)
}

#Preview("Dark - RU") {
    TripStatusView(status: .upcoming)
    TripStatusView(status: .ongoing)
    TripStatusView(status: .completed)
        .preferredColorScheme(.dark)
}
