//
//  CurrencyConverterView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.11.2026.
//

import SwiftUI

struct CurrencyConverterView: View {
    @Environment(\.haptics) private var haptics

    @State private var viewModel: CurrencyConverterViewModel
    @FocusState private var focusedField: NumericEditField?

    init(baseCurrency: Currency) {
        _viewModel = State(
            initialValue: CurrencyConverterViewModel(baseCurrency: baseCurrency)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                CurrencyConversionSection(
                    sourceAmount: sourceAmountBinding,
                    destinationAmount: viewModel.destinationAmount,
                    sourceCurrency: viewModel.sourceCurrency,
                    destinationCurrency: viewModel.destinationCurrency,
                    sourceCurrencySelection: sourceCurrencyBinding,
                    destinationCurrencySelection: destinationCurrencyBinding,
                    focusedField: $focusedField,
                    onSwap: swapCurrencies
                )

                ExchangeRateSection(
                    description: viewModel.rateDescription,
                    isLoading: viewModel.isRateLoading,
                    onRefresh: refreshRate
                )

                ConversionHistorySection(
                    records: viewModel.history,
                    onDelete: viewModel.deleteHistoryRecord,
                    onClear: { viewModel.clearHistory() }
                )
            }
            .navigationTitle(.converterNavigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.interactively)
            .task { viewModel.loadInitialRateIfNeeded() }
            .onChange(of: focusedField) { oldValue, newValue in
                if oldValue == .amount && newValue == nil {
                    viewModel.addCurrentConversionToHistory()
                }
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

    private var sourceAmountBinding: Binding<Double> {
        Binding(
            get: { viewModel.sourceAmount },
            set: { viewModel.updateSourceAmount($0) }
        )
    }

    private var sourceCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.sourceCurrency },
            set: { viewModel.updateSourceCurrency($0) }
        )
    }

    private var destinationCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.destinationCurrency },
            set: { viewModel.updateDestinationCurrency($0) }
        )
    }

    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }

    private func swapCurrencies() {
        haptics.trigger(.tap)
        viewModel.swapCurrencies()
    }

    private func refreshRate() {
        haptics.trigger(.tap)
        viewModel.refreshRate()
    }
}

private struct CurrencyConversionSection: View {
    @Binding var sourceAmount: Double

    let destinationAmount: Double
    let sourceCurrency: Currency
    let destinationCurrency: Currency
    let sourceCurrencySelection: Binding<Currency>
    let destinationCurrencySelection: Binding<Currency>
    let focusedField: FocusState<NumericEditField?>.Binding
    let onSwap: () -> Void

    var body: some View {
        Section {
            VStack(spacing: 12) {
                NumericInputField(
                    $sourceAmount,
                    focusedField: focusedField,
                    focusID: .amount,
                    fractionDigits: 2,
                    font: .largeTitle.monospacedDigit(),
                    textAlignment: .center
                )
                CurrencyCodeText.standard(sourceCurrency)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            LabeledPicker(
                title: .converterSourceCurrenency,
                selection: sourceCurrencySelection,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }

            Button(action: onSwap) {
                Image(systemName: "arrow.up.arrow.down")
                    .frame(maxWidth: .infinity)
            }

            LabeledPicker(
                title: .converterTargetCurrency,
                selection: destinationCurrencySelection,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }

//            LabeledContent(.amou) {
                Text(
                    destinationAmount,
                    format: .currency(code: destinationCurrency.code)
                        .precision(.fractionLength(0...2))
                )
                .font(.title3.monospacedDigit())
                .textSelection(.enabled)
//            }
        }
    }
}

private struct ExchangeRateSection: View {
    let description: LocalizedStringResource?
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        Section(.converterExchangeRate) {
            HStack {
                if let description = description {
                    Text(description)
                        .monospacedDigit()
                }
                Spacer()
                Button(action: onRefresh) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.borderless)
                .disabled(isLoading)
            }
        }
    }
}

private struct ConversionHistorySection: View {
    let records: [CurrencyConversionRecord]
    let onDelete: (CurrencyConversionRecord) -> Void
    let onClear: () -> Void

    var body: some View {
        Section {
            if !records.isEmpty {
                ForEach(records) { record in
                    ConversionHistoryRow(record: record)
                        .swipeActions {
                            Button(.delete, role: .destructive) {
                                onDelete(record)
                            }
                        }
                }
            }
        } header: {
            ZStack {
                Text(.converterRecent)
                if !records.isEmpty {
                    HStack {
                        Spacer()
                        Button("", role: .destructive, action: onClear)
                            .textCase(nil)
                    }
                }
            }
        }
    }
}

private struct ConversionHistoryRow: View {
    let record: CurrencyConversionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(
                    record.sourceAmount,
                    format: .currency(code: record.sourceCurrency.code)
                        .precision(.fractionLength(0...2))
                )
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                Text(
                    record.destinationAmount,
                    format: .currency(code: record.destinationCurrency.code)
                        .precision(.fractionLength(0...2))
                )
                .fontWeight(.semibold)
            }
            .monospacedDigit()

            HStack {
                Text(
                    "1 \(record.sourceCurrency.code) = \(record.rate.formatted(.number.precision(.fractionLength(0...4)))) \(record.destinationCurrency.code)"
                )
                Spacer()
                Text(record.date, format: .dateTime.day().month().hour().minute())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

