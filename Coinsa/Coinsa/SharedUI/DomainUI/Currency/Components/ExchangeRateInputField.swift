//
//  ExchangeRateInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

/// Поле для ввода курса обмена валюты с отображением кода валюты и кнопкой обновления.
struct ExchangeRateInputField: View {
    // MARK: - Свойства

    private let value: Binding<Double>
    private let currency: Currency
    private let isLoading: Bool
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusID: NumericEditField
    private let font: Font
    private let onRefresh: () -> Void

    // MARK: - Инициализация

    /// Создает поле для ввода курса обмена валюты.
    /// - Parameters:
    ///   - value: Привязка к значению курса.
    ///   - currency: Валюта, в которой выражен курс.
    ///   - isLoading: Флаг загрузки курса (показывает спиннер в кнопке обновления).
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusID: Уникальный идентификатор этого поля.
    ///   - font: Шрифт текста.
    ///   - onRefresh: Действие при нажатии кнопки обновления курса.
    init(
        _ value: Binding<Double>,
        currency: Currency,
        isLoading: Bool,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusID: NumericEditField,
        font: Font,
        onRefresh: @escaping () -> Void
    ) {
        self.value = value
        self.currency = currency
        self.isLoading = isLoading
        self.focusedField = focusedField
        self.focusID = focusID
        self.font = font
        self.onRefresh = onRefresh
    }

    // MARK: - Тело View

    var body: some View {
        HStack {
            NumericInputField(
                value,
                focusedField: focusedField,
                focusID: focusID,
                fractionDigits: 4,
                font: font,
                textAlignment: .trailing
            )
            .loadingState(isLoading)

            CurrencyCodeText.standard(currency)

            ExchangeRateRefreshButton(
                isLoading: isLoading,
                onRefresh: onRefresh
            )
        }
    }
}

// MARK: - Предопределенные варианты

extension ExchangeRateInputField {
    /// Стандартное поле для ввода курса с моноширинными цифрами.
    static func standard(
        _ value: Binding<Double>,
        currency: Currency,
        isLoading: Bool,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusID: NumericEditField,
        onRefresh: @escaping () -> Void
    ) -> some View {
        ExchangeRateInputField(
            value,
            currency: currency,
            isLoading: isLoading,
            focusedField: focusedField,
            focusID: focusID,
            font: .body.monospacedDigit(),
            onRefresh: onRefresh
        )
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var rate: Double = 80.1234
    @Previewable @FocusState var focusedField: NumericEditField?

    List {
        Section {
            ExchangeRateInputField.standard(
                $rate,
                currency: Currency.defaultValue,
                isLoading: false,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateInputField.standard(
                $rate,
                currency: Currency.defaultValue,
                isLoading: true,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                onRefresh: {}
            )
        }
    }
}
