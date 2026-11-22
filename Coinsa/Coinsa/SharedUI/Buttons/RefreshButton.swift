//
//  RefreshButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI

/// Общая кнопка обновления со спиннером на время выполнения действия.
struct RefreshButton: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства
    
    let isLoading: Bool
    let action: () -> Void

    // MARK: - Инициализация

    /// Создает кнопку обновления с необязательным состоянием загрузки.
    /// - Parameters:
    ///   - isLoading: Показывать спиннер и блокировать повторное нажатие.
    ///   - action: Действие обновления данных.
    init(isLoading: Bool = false, action: @escaping () -> Void) {
        self.isLoading = isLoading
        self.action = action
    }

    // MARK: - Тело View
    
    var body: some View {
        Button {
            haptics.trigger(.tap)
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    AppIcon(AppSymbols.arrowClockwise)
                        .foregroundStyle(.accent)
                }
            }
            .frame(width: ViewLayout.Label.inputAccessoryWidth)
        }
        .buttonStyle(.borderless)
        .disabled(isLoading)
    }
}

// MARK: - Превью

#Preview {
    HStack {
        RefreshButton {}
        RefreshButton(isLoading: true, action: {})
    }
}
