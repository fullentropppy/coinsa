//
//  View+KeyboardInputBar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

extension View {
    /// Добавляет панель очистки поля и закрытия клавиатуры; снятием фокуса управляет экран.
    func keyboardInputBar(isPresented: Bool, onDismiss: @escaping () -> Void) -> some View {
        self.modifier(
            KeyboardInputBarModifier(isPresented: isPresented, onDismiss: onDismiss)
        )
    }

    /// Подключает очистку текста активного поля к общей панели ввода.
    func keyboardClearAction(text: Binding<String>) -> some View {
        self.focusedValue(
            \.keyboardClearAction,
            KeyboardClearAction(isEmpty: text.wrappedValue.isEmpty) {
                text.wrappedValue = ""
            }
        )
    }
}
