//
//  KeyboardInputBarModifier.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Показывает панель очистки поля и закрытия клавиатуры с учетом настройки положения.
struct KeyboardInputBarModifier: ViewModifier {
    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics

    @FocusedValue(\.keyboardClearAction) private var clearAction

    // MARK: - Свойства
    
    private var buttonSideLength: CGFloat = 48
    
    let isPresented: Bool
    let onDismiss: () -> Void

    // MARK: - Тело View

    func body(content: Content) -> some View {
        content
            .safeAreaInset(
                edge: .bottom,
                alignment: settingsStore.isFloatingButtonOnLeft ? .leading : .trailing
            ) {
                if isPresented {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        if settingsStore.isFloatingButtonOnLeft {
                            dismissButton
                            Divider().frame(height: 20)
                            clearButton
                        } else {
                            clearButton
                            Divider().frame(height: 20)
                            dismissButton
                        }
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
    }

    // MARK: - Компоненты

    private var clearButton: some View {
        Button {
            haptics.trigger(.tap)
            clearAction?.clear()
        } label: {
            Image(systemName: "xmark.rectangle")
        }
        .padding(.vertical, 16)
        .padding(.leading, settingsStore.isFloatingButtonOnLeft ? 10 : 16)
        .padding(.trailing, settingsStore.isFloatingButtonOnLeft ? 16 : 10)
        .disabled(clearAction?.isEmpty ?? true)
    }

    private var dismissButton: some View {
        Button {
            haptics.trigger(.tap)
            onDismiss()
        } label: {
            Image(systemName: "keyboard.chevron.compact.down")
        }
        .padding(.vertical, 16)
        .padding(.leading, settingsStore.isFloatingButtonOnLeft ? 16 : 10)
        .padding(.trailing, settingsStore.isFloatingButtonOnLeft ? 10 : 16)
    }
}
