//
//  EmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Свойства
    
    private let icon: String
    private let title: LocalizedStringResource
    private let description: LocalizedStringResource
    private let buttonLabel: LocalizedStringResource?
    private let onAddAction: (() -> Void)?
    
    // MARK: - Инициализация
    
    init(
        icon: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        buttonLabel: LocalizedStringResource? = nil,
        onAddAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.onAddAction = onAddAction
    }
    
    // MARK: - Тело View
    
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
    
    // MARK: - Компоненты
    
    private var titleContent: some View {
        Label(title, systemImage: icon)
    }
    
    private var descriptionContent: some View {
        Text(description)
            .padding()
    }
}

// MARK: - Превью

private extension EmptyStateView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        EmptyStateView(
            icon: Trip.primaryIcon,
            title: .tripEmptyStateTitle,
            description: .tripEmptyStateDescription,
            buttonLabel: .tripAdd,
            onAddAction: {}
        )
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EmptyStateView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EmptyStateView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
