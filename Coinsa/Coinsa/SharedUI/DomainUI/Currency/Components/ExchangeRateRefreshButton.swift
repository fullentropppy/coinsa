//
//  ExchangeRateRefreshButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.11.2026.
//

import SwiftUI

/// Кнопка обновления курса со спиннером в состоянии загрузки.
struct ExchangeRateRefreshButton: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства
    
    let isLoading: Bool
    let onRefresh: () -> Void

    // MARK: - Тело View
    
    var body: some View {
        Button {
            haptics.trigger(.tap)
            onRefresh()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.small)
                        .fontWeight(.semibold)
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
        ExchangeRateRefreshButton(isLoading: false, onRefresh: {})
        ExchangeRateRefreshButton(isLoading: true, onRefresh: {})
    }
}
