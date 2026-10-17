//
//  ExchangeRateInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

/// Поле для ввода курса обмена валюты с отображением кода валюты и кнопкой обновления.
struct ExchangeRateInputField: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let value: Binding<Double>
    private let currency: Currency
    private let isLoading: Bool
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusID: NumericEditField
    private let font: Font
    private let onRefresh: () -> Void
    
    // MARK: - Инициализация
    
    /// Создает поле для ввода курса обмена.
    /// - Parameters:
    ///   - value: Привязка к значению курса.
    ///   - currency: Валюта.
    ///   - isLoading: Флаг загрузки.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusID: Уникальный идентификатор поля.
    ///   - font: Шрифт текста.
    ///   - onRefresh: Действие при нажатии кнопки обновления.
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
            inputField
            CurrencyCodeText.standard(currency)
            refreshButton
        }
    }
    
    // MARK: - Компоненты
    private var inputField: some View {
        NumericInputField(
            value,
            focusedField: focusedField,
            focusID: focusID,
            fractionDigits: 4,
            font: font,
            textAlignment: .trailing
        )
        .loadingState(isLoading)
    }
    
    private var refreshButton: some View {
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
            .frame(width: 16)
        }
        .buttonStyle(.borderless)
        .disabled(isLoading)
    }
}

// MARK: - Предопределенные варианты

extension ExchangeRateInputField {
    /// Стандартное поле для ввода курса с моноширинными цифрами.
    /// - Parameters:
    ///   - value: Привязка к значению курса.
    ///   - currency: Валюта.
    ///   - isLoading: Флаг загрузки.
    ///   - focusedField: Привязка к фокусированному полю.
    ///   - focusID: Уникальный идентификатор поля.
    ///   - onRefresh: Действие при нажатии кнопки обновления.
    /// - Returns: Настроенное поле ввода.
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

    let currency = Currency.defaultValue

    List {
        Section {
            ExchangeRateInputField(
                $rate,
                currency: currency,
                isLoading: false,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                font: .body,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateInputField.standard(
                $rate,
                currency: currency,
                isLoading: false,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateInputField(
                $rate,
                currency: currency,
                isLoading: true,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                font: .body,
                onRefresh: {}
            )
        }
        Section {
            ExchangeRateInputField.standard(
                $rate,
                currency: currency,
                isLoading: true,
                focusedField: $focusedField,
                focusID: .exchangeRate,
                onRefresh: {}
            )
        }
    }
}
