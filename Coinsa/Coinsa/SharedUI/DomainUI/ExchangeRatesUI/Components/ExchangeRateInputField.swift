//
//  ExchangeRateInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

struct ExchangeRateInputField: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    private let value: Binding<Double>
    private let currency: Currency
    private let isLoading: Bool
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let font: Font
    private let action: () -> Void
    
    // MARK: - Инициализация
    
    init(
        _ value: Binding<Double>,
        currency: Currency,
        isLoading: Bool,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        font: Font,
        onRefresh: @escaping () -> Void
    ) {
        self.value = value
        self.currency = currency
        self.isLoading = isLoading
        self.focusedField = focusedField
        self.focusId = focusId
        self.font = font
        self.action = onRefresh
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
            focusId: focusId,
            fractionDigits: 4,
            font: font
        )
        .loadingState(isLoading)
    }
    
    private var refreshButton: some View {
        Button {
            haptics.trigger(.tap)
            action()
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
    static func standard(
        _ value: Binding<Double>,
        currency: Currency,
        isLoading: Bool,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        onRefresh: @escaping () -> Void
    ) -> some View {
        ExchangeRateInputField(
            value,
            currency: currency,
            isLoading: isLoading,
            focusedField: focusedField,
            focusId: focusId,
            font: .body.monospacedDigit(),
            onRefresh: onRefresh
        )
    }
}

// MARK: - Превью

private extension ExchangeRateInputField {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        List {
            ExchangeRateInputFieldPreview(isLoading: false)
            ExchangeRateInputFieldPreview(isLoading: true)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
    
    struct ExchangeRateInputFieldPreview: View {
        @State private var rate: Double = 80.1234
        @FocusState private var focusedField: NumericEditField?
        
        private var currency = Currency.defaultValue
        private var isLoading: Bool
        
        init(isLoading: Bool) {
            self.isLoading = isLoading
        }
        
        var body: some View {
            Section {
                ExchangeRateInputField(
                    $rate,
                    currency: currency,
                    isLoading: isLoading,
                    focusedField: $focusedField,
                    focusId: .exchangeRate,
                    font: .body,
                    onRefresh: {}
                )
            }
            Section {
                ExchangeRateInputField.standard(
                    $rate,
                    currency: currency,
                    isLoading: isLoading,
                    focusedField: $focusedField,
                    focusId: .exchangeRate,
                    onRefresh: {}
                )
            }
        }
    }
}

#Preview("Light - RU") {
    ExchangeRateInputField.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExchangeRateInputField.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
