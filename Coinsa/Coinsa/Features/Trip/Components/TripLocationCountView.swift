//
//  TripLocationCountView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

import SwiftUI

struct TripLocationCountView: View {
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

private extension TripLocationCountView {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            TripLocationCountView(count: 1)
            TripLocationCountView(count: 5)
            TripLocationCountView(count: 10)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    TripLocationCountView.preview(colorScheme: .light)
}

#Preview("Dark") {
    TripLocationCountView.preview(colorScheme: .dark)
}
