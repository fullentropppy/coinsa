//
//  LocationEmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

struct LocationEmptyStateView: View {
    // MARK: - Stored Properties
    
    let onAddLocation: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ContentUnavailableView {
            Label("location.list.empty.title", systemImage: "mappin.and.ellipse")
        } description: {
            Text("location.list.empty.desctiption")
                .padding()
        } actions: {
            Button("location.list.addLocation") {
                onAddLocation()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    LocationEmptyStateView {}
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    LocationEmptyStateView {}
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
