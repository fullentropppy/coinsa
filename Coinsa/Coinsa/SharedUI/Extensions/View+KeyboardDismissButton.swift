//
//  View+KeyboardDismissButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

extension View {
    /// Добавляет общую кнопку закрытия клавиатуры; снятием фокуса управляет экран.
    func keyboardDismissButton(isPresented: Bool, onDismiss: @escaping () -> Void) -> some View {
        self.modifier(
            KeyboardDismissButtonModifier(isPresented: isPresented, onDismiss: onDismiss)
        )
    }
}
