//
//  KeyboardInputBarModifier.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Показывает панель очистки поля и закрытия клавиатуры с учетом настройки положения.
struct KeyboardInputBarModifier: ViewModifier {
    // MARK: - Константы

    private enum Layout {
        /// Высота разделителя между кнопками панели клавиатуры.
        static let dividerHeight: CGFloat = 20
        /// Отступ кнопки со стороны центрального разделителя.
        static let innerButtonInset: CGFloat = 10
    }

    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics

    @FocusedValue(\.keyboardClearAction) private var clearAction

    // MARK: - Свойства
    
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
                            Divider().frame(height: Layout.dividerHeight)
                            clearButton
                        } else {
                            clearButton
                            Divider().frame(height: Layout.dividerHeight)
                            dismissButton
                        }
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .padding(.horizontal, ViewLayout.FloatingControls.edgeInset)
                    .padding(.bottom, ViewLayout.FloatingControls.edgeInset)
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
        .padding(.vertical, ViewLayout.FloatingControls.buttonInset)
        .padding(
            .leading,
            settingsStore.isFloatingButtonOnLeft ? Layout.innerButtonInset : ViewLayout.FloatingControls.buttonInset
        )
        .padding(
            .trailing,
            settingsStore.isFloatingButtonOnLeft ? ViewLayout.FloatingControls.buttonInset : Layout.innerButtonInset
        )
        .disabled(clearAction?.isEmpty ?? true)
    }

    private var dismissButton: some View {
        Button {
            haptics.trigger(.tap)
            onDismiss()
        } label: {
            Image(systemName: "keyboard.chevron.compact.down")
        }
        .padding(.vertical, ViewLayout.FloatingControls.buttonInset)
        .padding(
            .leading,
            settingsStore.isFloatingButtonOnLeft ? ViewLayout.FloatingControls.buttonInset : Layout.innerButtonInset
        )
        .padding(
            .trailing,
            settingsStore.isFloatingButtonOnLeft ? Layout.innerButtonInset : ViewLayout.FloatingControls.buttonInset
        )
    }
}
