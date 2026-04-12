//
//  ExchangeRateInputField.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

struct ExchangeRateInputField: View {
    // MARK: - Properties
    private let value: Binding<Double>
    private let currency: Currency
    private let isLoading: Bool
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let focusId: NumericEditField
    private let onRefresh: () -> Void
    
    // MARK: - Initializers
    init(
        _ value: Binding<Double>,
        currency: Currency,
        isLoading: Bool,
        focusedField: FocusState<NumericEditField?>.Binding,
        focusId: NumericEditField,
        onRefresh: @escaping () -> Void
    ) {
        self.value = value
        self.currency = currency
        self.isLoading = isLoading
        self.focusedField = focusedField
        self.focusId = focusId
        self.onRefresh = onRefresh
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            inputField
            CurrencyCodeText(currency)
            refreshButton
        }
    }
    
    // MARK: - Components
    private var inputField: some View {
        NumericInputField(
            value,
            focusedField: focusedField,
            focusId: .exchangeRate,
            fractionDigits: 4,
        )
        .loadingState(isLoading)
    }
    
    private var refreshButton: some View {
        Button(action: onRefresh) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .fontWeight(.semibold)
                        .imageScale(.small)
                        .foregroundStyle(.accent)
                }
            }
            .frame(width: 16)
        }
        .buttonStyle(.borderless)
        .disabled(isLoading)
    }
}

// MARK: - Preview
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
        
        private var currency = Currency.usd
        private var isLoading: Bool
        
        init(isLoading: Bool) {
            self.isLoading = isLoading
        }
        
        var body: some View {
            LabeledContent(.expenseExchangeRate(localCurrencyCode: currency.code)) {
                ExchangeRateInputField(
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
