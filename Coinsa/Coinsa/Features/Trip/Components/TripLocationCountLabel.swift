//
//  TripLocationCountLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

import SwiftUI

struct TripLocationCountLabel: View {
    // MARK: - Stored Properties
    
    let count: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "mappin.and.ellipse")
            Text(String(count))
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Previews

private extension TripLocationCountLabel {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            TripLocationCountLabel(count: 1)
            TripLocationCountLabel(count: 5)
            TripLocationCountLabel(count: 10)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    TripLocationCountLabel.preview(colorScheme: .light)
}

#Preview("Dark") {
    TripLocationCountLabel.preview(colorScheme: .dark)
}
