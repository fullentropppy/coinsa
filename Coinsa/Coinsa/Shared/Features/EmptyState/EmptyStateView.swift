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
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let buttonLabel: LocalizedStringResource
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
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        EmptyStateView(
            imageName: Trip.primaryIcon,
            title: .tripEmptyStateTitle,
            description: .tripEmptyStateDesctiption,
            buttonLabel: .tripAdd,
            onAddAction: {}
        )
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EmptyStateView.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EmptyStateView.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
