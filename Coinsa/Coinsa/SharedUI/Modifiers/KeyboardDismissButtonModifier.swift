//
//  KeyboardDismissButtonModifier.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Показывает плавающую кнопку закрытия клавиатуры с учетом настройки положения.
struct KeyboardDismissButtonModifier: ViewModifier {
    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore

    // MARK: - Свойства

    let isPresented: Bool
    let onDismiss: () -> Void

    // MARK: - Тело View

    func body(content: Content) -> some View {
        content
            .safeAreaBar(
                edge: .bottom,
                alignment: settingsStore.isFloatingButtonOnLeft ? .leading : .trailing
            ) {
                if isPresented {
                    Button(action: onDismiss) {
                        Label(.done, systemImage: "keyboard.chevron.compact.down")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
    }
}
