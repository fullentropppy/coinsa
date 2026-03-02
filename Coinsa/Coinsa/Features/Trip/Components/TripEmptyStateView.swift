//
//  TripEmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import SwiftUI

struct TripEmptyStateView: View {
    // MARK: - Stored properties
    
    let onAddTrip: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ContentUnavailableView {
            Label("trip.list.empty.title", systemImage: "suitcase")
        } description: {
            Text("trip.list.empty.desctiption")
                .padding()
        } actions: {
            Button("trip.list.addTrip") {
                onAddTrip()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
        TripEmptyStateView {}
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
        TripEmptyStateView {}
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
}
