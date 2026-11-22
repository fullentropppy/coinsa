//
//  ClearButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Кнопка очистки содержимого.
struct ClearButton: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    private let showsTitle: Bool
    let action: () -> Void

    // MARK: - Инициализация

    /// Создает кнопку очистки с необязательной видимой подписью.
    /// - Parameters:
    ///   - showsTitle: Показывать текст рядом с иконкой.
    ///   - action: Действие очистки содержимого.
    init(showsTitle: Bool = true, action: @escaping () -> Void) {
        self.showsTitle = showsTitle
        self.action = action
    }

    // MARK: - Тело View

    var body: some View {
        Button(role: .destructive) {
            haptics.trigger(.tap)
            action()
        } label: {
            HStack(spacing: ViewLayout.Label.compactIconSpacing) {
                AppIcon(AppSymbols.xmarkCircleFill)
                if showsTitle {
                    Text(.clear)
                        .font(.footnote)
                }
            }
        }
    }
}

// MARK: - Превью

#Preview {
    HStack(spacing: 20) {
        ClearButton {}
        ClearButton(showsTitle: false) {}
        ClearButton {}
            .disabled(true)
    }
    .padding()
}
