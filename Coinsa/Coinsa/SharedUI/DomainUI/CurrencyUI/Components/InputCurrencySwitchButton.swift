//
//  InputCurrencySwitchButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

/// Кнопка для переключения между валютами ввода.
struct InputCurrencySwitchButton: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    let action: () -> Void
    
    // MARK: - Тело View
    
    var body: some View {
        Button {
            haptics.trigger(.tap)
            action()
        } label: {
            Image(systemName: "arrow.left.arrow.right")
                .imageScale(.small)
                .fontWeight(.semibold)
        }
        .frame(width: 16)
        .buttonStyle(.borderless)
        .foregroundStyle(.accent)
    }
}

// MARK: - Превью

private extension InputCurrencySwitchButton {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        InputCurrencySwitchButton(action: {})
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    InputCurrencySwitchButton.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    InputCurrencySwitchButton.makePreview(colorScheme: .dark)
}
