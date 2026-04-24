//
//  EmptyStateView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let icon: String
    private let title: LocalizedStringResource
    private let description: LocalizedStringResource?
    private let buttonLabel: LocalizedStringResource?
    private let action: (() -> Void)?
    
    // MARK: - Инициализация
    
    init(
        icon: String,
        title: LocalizedStringResource,
        description: LocalizedStringResource? = nil,
        buttonLabel: LocalizedStringResource? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.buttonLabel = buttonLabel
        self.action = action
    }
    
    // MARK: - Тело View
    
    var body: some View {
        ContentUnavailableView {
            titleContent
        } description: {
            descriptionContent
        } actions: {
            buttonContent
        }
    }
    
    // MARK: - Компоненты
    
    private var titleContent: some View {
        Label(title, systemImage: icon)
    }
    
    @ViewBuilder
    private var descriptionContent: some View {
        if let description {
            Text(description)
                .padding()
        }
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        if let buttonLabel, let action {
            Button(buttonLabel) {
                haptics.trigger(.add)
                action()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
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
            action: {}
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
