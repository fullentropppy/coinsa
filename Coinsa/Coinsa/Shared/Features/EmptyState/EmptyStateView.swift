//
//  EmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Stored Properties
    
    private let imageName: String
    private let title: LocalizedStringResource
    private let description: LocalizedStringResource
    private let buttonLabel: LocalizedStringResource?
    private let onAddAction: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        imageName: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        buttonLabel: LocalizedStringResource? = nil,
        onAddAction: (() -> Void)? = nil
    ) {
        self.imageName = imageName
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.onAddAction = onAddAction
    }
    
    // MARK: - Body
    
    var body: some View {
        if let buttonLabel, let onAddAction {
            ContentUnavailableView {
                titleContent
            } description: {
                descriptionContent
            } actions: {
                Button(buttonLabel) {
                    onAddAction()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
            }
        } else {
            ContentUnavailableView {
                titleContent
            } description: {
                descriptionContent
            }
        }
    }
    
    // MARK: - Components
    
    private var titleContent: some View {
        Label(title, systemImage: imageName)
    }
    
    private var descriptionContent: some View {
        Text(description)
            .padding()
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
