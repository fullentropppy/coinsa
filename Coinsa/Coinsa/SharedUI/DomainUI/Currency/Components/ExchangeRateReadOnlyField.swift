//
//  ExchangeRateReadOnlyField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.11.2026.
//

import SwiftUI

/// Поле только для чтения курса обмена валюты с кнопкой обновления курса.
struct ExchangeRateReadOnlyField: View {
    // MARK: - Свойства

    private let value: Double
    private let currency: Currency
    private let isLoading: Bool
    private let onRefresh: () -> Void

    // MARK: - Инициализация

    /// Создает поле только для чтения курса обмена валюты.
    /// - Parameters:
    ///   - value: Значение курса.
    ///   - currency: Валюта, в которой выражен курс.
    ///   - isLoading: Флаг загрузки курса (показывает спиннер в кнопке обновления).
    ///   - onRefresh: Действие при нажатии кнопки обновления курса.
    init(
        _ value: Double,
        currency: Currency,
        isLoading: Bool,
        onRefresh: @escaping () -> Void
    ) {
        self.value = value
        self.currency = currency
        self.isLoading = isLoading
        self.onRefresh = onRefresh
    }

    // MARK: - Тело View

    var body: some View {
        HStack {
            Text(displayText)
                .font(.body.monospacedDigit())
                .foregroundStyle(isLoading ? .secondary : .primary)
                .lineLimit(1)
            CurrencyCodeText.standard(currency)
            ExchangeRateRefreshButton(isLoading: isLoading, onRefresh: onRefresh)
        }
    }

    // MARK: - Приватные методы

    private var displayText: String {
        guard value > 0 else { return "0" }
        return value.numberFormat(fractionLength: 4)
    }
}

// MARK: - Превью

#Preview {
    List {
        Section {
            ExchangeRateReadOnlyField(
                80.1234,
                currency: Currency.defaultValue,
                isLoading: false,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateReadOnlyField(
                80.1234,
                currency: Currency.defaultValue,
                isLoading: true,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateReadOnlyField(
                0,
                currency: Currency.defaultValue,
                isLoading: false,
                onRefresh: {}
            )
        }
    }
}
