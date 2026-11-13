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
    // MARK: - Константы

    private enum Layout {
        /// Интервал между подписью валюты и строкой ввода суммы.
        static let amountRowSpacing: CGFloat = 10
        /// Интервал между элементами управления валютной парой.
        static let currencyPairSpacing: CGFloat = 10
        /// Ширина кнопки очистки суммы в конвертере.
        static let clearButtonWidth: CGFloat = 42
        /// Внутренние отступы строки суммы в конвертере.
        static let amountRowInset: CGFloat = 12
        /// Радиус скругления строки суммы в конвертере.
        static let amountRowCornerRadius: CGFloat = 12
    }

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
                    viewModel.restorePersistedState(
                        amount: settingsStore.converterAmount,
                        base: settingsStore.converterBaseCurrency,
                        quote: settingsStore.converterQuoteCurrency
                    )
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
                .onChange(of: viewModel.input.text) { _, _ in
                    settingsStore.converterAmount = viewModel.input.value
                }
                .onChange(of: viewModel.baseCurrency) { _, _ in
                    settingsStore.converterBaseCurrency = viewModel.baseCurrency
                }
                .onChange(of: viewModel.quoteCurrency) { _, _ in
                    settingsStore.converterQuoteCurrency = viewModel.quoteCurrency
                }
        }
    }

    // MARK: - Основной контент

    private var converterForm: some View {
        Form {
            amountRow(for: .base)
            amountRow(for: .quote)
            rateRow
        }
    }

    // MARK: - Компоненты

    private func amountRow(for side: CurrencyPairSide) -> some View {
        let isBase = side == .base
        let currency = isBase ? viewModel.baseCurrency : viewModel.quoteCurrency
        let displayText = viewModel.displayText(for: side)

        return VStack(spacing: Layout.amountRowSpacing) {
            LabeledPicker(
                title: isBase ? .converterFromCurrenency : .converterToCurrency,
                selection: isBase ? fromCurrencyBinding : toCurrencyBinding,
                sections: Currency.pickerSections(
                    homeCurrency: settingsStore.homeCurrency,
                    locationCurrency: currentLocationCurrency
                )
            ) { currency in
                currency.makeLabel()
            } currentValueLabel: { currency in
                Text(currency.localizedResource)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(displayText.isEmpty ? 0.numberFormat() : displayText)
                    .font(.largeTitle.monospacedDigit())
                    .foregroundStyle(isBase ? Color.primary : Color.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                CurrencyCodeText(
                    currency,
                    font: .title2.monospaced().weight(.medium),
                    color: isBase ? Color.primary : Color.secondary
                )
                .frame(width: Layout.clearButtonWidth)
            }
            .padding(.vertical, Layout.amountRowInset)
            .padding(.horizontal, Layout.amountRowInset)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: .rect(cornerRadius: Layout.amountRowCornerRadius))
        }
    }

    private var rateRow: some View {
        HStack(alignment: .center, spacing: Layout.currencyPairSpacing) {
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

            HStack(spacing: ViewLayout.Label.iconSpacing) {
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
                viewModel.input.append(digit)
            },
            onDelete: {
                viewModel.input.deleteLast()
            },
            onClear: {
                haptics.trigger(.tap)
                viewModel.input.clear()
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
