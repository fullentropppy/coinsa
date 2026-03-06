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

#Preview("Light") {
    TripLocationCountView(count: 1)
    TripLocationCountView(count: 5)
    TripLocationCountView(count: 10)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    TripLocationCountView(count: 1)
    TripLocationCountView(count: 5)
    TripLocationCountView(count: 10)
        .preferredColorScheme(.dark)
}
