//
//  CurrencyConverterView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.11.2026.
//

import SwiftUI

/// Экран конвертера валют.
struct CurrencyConverterView: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var viewModel = CurrencyCurrencyConverterViewModel()

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
            LabeledPicker(
                title: "From",
                selection: fromCurrencyBinding,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }
            .listRowSeparator(.hidden)
            
            amountButton(for: .base)
                .listRowSeparator(.visible)
                
            LabeledPicker(
                title: "To",
                selection: toCurrencyBinding,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }
            .listRowSeparator(.hidden)
            
            amountButton(for: .quote)
                .listRowSeparator(.visible)
            
            HStack(alignment: .center) {
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
                
                if viewModel.isRateLoading {
                    ProgressView()
                        .controlSize(.small)
                }
                    
                Text(
                    "1 \(viewModel.fromCurrency.code) = \(viewModel.unitRateDescription) \(viewModel.toCurrency.code)"
                )
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
                    
                Button {
                    haptics.trigger(.tap)
                    viewModel.requestRateRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isRateLoading)
            }
        }
    }

    // MARK: - Секции

//    private var fromSection: some View {
//
//    }
//
//    private var swapSection: some View {
//
//    }
//
//    private var toSection: some View {
//
//    }
//
//    private var rateSection: some View {
//
//    }

    // MARK: - Компоненты

    private func amountButton(for side: CurrencySide) -> some View {
        let currency = side == .base ? viewModel.fromCurrency : viewModel.toCurrency
        let displayText = viewModel.displayText(for: side)
        let isActive = viewModel.isActive(side)

        return Button {
            viewModel.setActiveSide(side)
        } label: {
            HStack(alignment: .center) {
                Text(displayText.isEmpty ? "0" : displayText)
                    .font(.title.monospacedDigit())
                    .foregroundStyle(
                        isActive ? Color.primary : Color.secondary
                    )
                    .lineLimit(1)

                Spacer()

                CurrencyCodeText(currency, font: .title3, color: isActive ? Color.primary : Color.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.glass)
    }

    private var numericKeypad: some View {
        NumericKeypad(
            onDigit: { digit in
                viewModel.append(digit)
            },
            onDelete: {
                viewModel.deleteLast()
            }
        )
    }

    // MARK: - Биндинги

    private var fromCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.fromCurrency },
            set: { viewModel.updateFromCurrency($0) }
        )
    }

    private var toCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.toCurrency },
            set: { viewModel.updateToCurrency($0) }
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
}
