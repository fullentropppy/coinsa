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

private extension EmptyStateView {
    static func tripPreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        EmptyStateView(
            imageName: "suitcase",
            title: "trip.list.empty.title",
            description: "trip.list.empty.desctiption",
            buttonLabel: "trip.list.addTrip",
            onAddAction: {}
        )
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
    
    static func locationPreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        EmptyStateView(
            imageName: "mappin.and.ellipse",
            title: "location.list.empty.title",
            description: "location.list.empty.desctiption",
            buttonLabel: "location.list.addLocation",
            onAddAction: {}
        )
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Trip. Light - RU") {
    EmptyStateView.tripPreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Trip. Dark - EN") {
    EmptyStateView.tripPreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#Preview("Location. Light - RU") {
    EmptyStateView.locationPreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Location. Dark - EN") {
    EmptyStateView.locationPreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
