//
//  EmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Stored Properties
    
    let imageName: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let buttonLabel: LocalizedStringKey
    let onAddAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: imageName)
        } description: {
            Text(description)
                .padding()
        } actions: {
            Button(buttonLabel) {
                onAddAction()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - Previews

private var tripEmptyStateView: some View {
    EmptyStateView(
        imageName: "suitcase",
        title: "trip.list.empty.title",
        description: "trip.list.empty.desctiption",
        buttonLabel: "trip.list.addTrip",
        onAddAction: {}
    )
}

private var locationEmptyStateView: some View {
    EmptyStateView(
        imageName: "mappin.and.ellipse",
        title: "location.list.empty.title",
        description: "location.list.empty.desctiption",
        buttonLabel: "location.list.addLocation",
        onAddAction: {}
    )
}

#Preview("Trip. Light - RU") {
    tripEmptyStateView
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Trip. Dark - EN") {
    tripEmptyStateView
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Location. Light - RU") {
    locationEmptyStateView
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Location. Dark - EN") {
    locationEmptyStateView
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
