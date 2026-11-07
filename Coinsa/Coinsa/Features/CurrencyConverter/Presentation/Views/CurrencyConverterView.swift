//
//  CurrencyConverterView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import SwiftUI
import SwiftData

/// Экран конвертера валют.
struct CurrencyConverterView: View {
    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel = CurrencyConverterViewModel()

    @Query private var locations: [Location]
    
    // MARK: - Свойства
    
    private var currentLocationCurrency: Currency? {
        guard let selectedID = settingsStore.selectedLocationID else { return nil }
        return locations.first(where: { $0.id == selectedID })?.locationCurrency
    }
    
    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            converterForm
                .navigationTitle(.converterNavigationTitle)
                .scrollDisabled(true)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    numericKeypad
                }
                .task {
                    viewModel.loadInitialRateIfNeeded()
                }
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    ),
                    isError: true
                )
        }
    }

    // MARK: - Основной контент

    private var converterForm: some View {
        Form {
            VStack(spacing: 8) {
                LabeledPicker(
                    title: .converterFromCurrenency,
                    selection: fromCurrencyBinding,
                    sections: Currency.pickerSections(
                        homeCurrency: settingsStore.homeCurrency,
                        locationCurrency: currentLocationCurrency
                    )
                ) { currency in
                    currency.makeLabel()
                }
                .listRowSeparator(.hidden)
                
                amountRow(for: .base)
                    .listRowSeparator(.visible)
                
            }
            
            VStack(spacing: 8) {
                LabeledPicker(
                    title: .converterToCurrency,
                    selection: toCurrencyBinding,
                    sections: Currency.pickerSections(
                        homeCurrency: settingsStore.homeCurrency,
                        locationCurrency: currentLocationCurrency
                    )
                ) { currency in
                    currency.makeLabel()
                }
                .listRowSeparator(.hidden)
                
                amountRow(for: .quote)
                    .listRowSeparator(.visible)
                
            }
            
            rateRow
        }
    }

    // MARK: - Компоненты

    private func amountRow(for side: CurrencyPairSide) -> some View {
        let currency = side == .base ? viewModel.baseCurrency : viewModel.quoteCurrency
        let displayText = viewModel.displayText(for: side)
        let isBase = side == .base

        return HStack(alignment: .center) {
            Text(displayText.isEmpty ? "0" : displayText)
                .font(.title.monospacedDigit())
                .foregroundStyle(isBase ? Color.primary : Color.secondary)
                .lineLimit(1)

            Spacer()

            CurrencyCodeText(
                currency,
                font: .title3,
                color: isBase ? Color.primary : Color.secondary
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }

    private var rateRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                haptics.trigger(.tap)
                viewModel.swapCurrencies()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.medium)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.glassProminent)

            Spacer()

            HStack(spacing: 4) {
                AmountText.standard(1.0, fractionLength: 0, currency: viewModel.baseCurrency)
                
                Image(systemName: "equal")
                    .imageScale(.small)
                
                ExchangeRateReadOnlyField(
                    viewModel.unitRate,
                    currency: viewModel.quoteCurrency,
                    isLoading: viewModel.isRateLoading,
                    onRefresh: { viewModel.requestRateRefresh() }
                )
            }
        }
    }

    private var numericKeypad: some View {
        NumericKeypad(
            onDigit: { digit in
                viewModel.append(digit)
            },
            onDelete: {
                viewModel.deleteLast()
            },
            onClear: {
                haptics.trigger(.tap)
                viewModel.clearInput()
            }
        )
    }

    // MARK: - Биндинги

    private var fromCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.baseCurrency },
            set: { viewModel.updateBaseCurrency($0) }
        )
    }

    private var toCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.quoteCurrency },
            set: { viewModel.updateQuoteCurrency($0) }
        )
    }

    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { shows in
                if !shows {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }
}

// MARK: - Превью

#Preview {
    CurrencyConverterView()
        .environment(AppSettingsStore())
}
