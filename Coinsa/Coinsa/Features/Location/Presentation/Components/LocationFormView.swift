//
//  LocationFormView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Форма локации с секциями и привязками к общему черновику и фокусу редактора.
struct LocationFormView: View {
    // MARK: - Свойства

    @Bindable private var viewModel: LocationEditViewModel
    private let inputCurrency: CurrencyContext
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let isNameFocused: FocusState<Bool>.Binding
    private let onSwitchInputCurrency: () -> Void
    private let onDelete: () -> Void

    // MARK: - Инициализация

    /// Создает секции, используя черновик и управление фокусом родительского редактора.
    /// - Parameters:
    ///   - viewModel: Общий черновик локации.
    ///   - inputCurrency: Текущая валюта ввода бюджета.
    ///   - focusedField: Фокус числовых полей, принадлежащий контейнеру.
    ///   - isNameFocused: Фокус названия, принадлежащий контейнеру.
    ///   - onSwitchInputCurrency: Переключение валюты с завершением текущего ввода.
    ///   - onDelete: Запрос подтверждения удаления.
    init(
        viewModel: LocationEditViewModel,
        inputCurrency: CurrencyContext,
        focusedField: FocusState<NumericEditField?>.Binding,
        isNameFocused: FocusState<Bool>.Binding,
        onSwitchInputCurrency: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.inputCurrency = inputCurrency
        self.focusedField = focusedField
        self.isNameFocused = isNameFocused
        self.onSwitchInputCurrency = onSwitchInputCurrency
        self.onDelete = onDelete
    }

    // MARK: - Вычисляемые свойства

    private var budgetInputCurrencyValue: Currency {
        switch inputCurrency {
        case .home: viewModel.homeCurrency
        case .location, .expense: viewModel.locationCurrency
        }
    }

    // MARK: - Тело View

    var body: some View {
        Form {
            titleSection
            rangeSection
            currencySection
            exchangeRateSection
            exchangeAdjustmentSection
            budgetsSection
            actionsSection
        }
    }

    // MARK: - Секции

    private var titleSection: some View {
        Section {
            TextField(.locationNamePlaceholder, text: $viewModel.name)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .focused(isNameFocused)
                .keyboardClearAction(text: $viewModel.name)
        }
        .listRowBackground(Color.clear)
    }

    private var rangeSection: some View {
        Section {
            DatePicker(
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0 }
                ),
                in: viewModel.availableRangeForStartDate,
                displayedComponents: .date
            ) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.secondary)
                    Text(.locationStartDate)
                }
            }
            .environment(\.timeZone, .utc)
            DatePicker(
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0 }
                ),
                in: viewModel.availableRangeForEndDate,
                displayedComponents: .date
            ) {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundStyle(.secondary)
                    Text(.locationEndDate)
                }
            }
            .environment(\.timeZone, .utc)
        } footer: {
            Text(.totalDays(totalDays: viewModel.totalDays))
        }
    }

    private var currencySection: some View {
        Section {
            LabeledPicker(
                title: .locationCurrency,
                selection: locationCurrencyBinding,
                sections: Currency.pickerSections(
                    homeCurrency: viewModel.homeCurrency,
                    locationCurrency: viewModel.locationCurrency
                ),
                isDisabled: viewModel.hasExpenses
            ) { currency in
                currency.makeLabel()
            } currentValueLabel: { currency in
                CurrencyCodeText.standard(currency)
            }
        } footer: {
            Text(.locationCurrencyHint)
        }
    }

    @ViewBuilder
    private var exchangeRateSection: some View {
        if !viewModel.isHomeLocation {
            Section {
                LabeledContent(.locationExchangeRate(locationCurrencyCode: viewModel.locationCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateInputBinding,
                        currency: viewModel.homeCurrency,
                        isLoading: viewModel.isRateLoading,
                        focusedField: focusedField,
                        focusID: .exchangeRate,
                        onRefresh: { viewModel.requestRateRefresh(for: inputCurrency) }
                    )
                }
            } footer: {
                Text(.locationExchangeRateHint)
            }
        }
    }

    @ViewBuilder
    private var exchangeAdjustmentSection: some View {
        if !viewModel.isHomeLocation {
            Section {
                LabeledContent(.locationExchangeAdjustment) {
                    PercentInputField.standard(
                        $viewModel.exchangeAdjustment,
                        focusedField: focusedField,
                        focusID: .exchangeAdjustment
                    )
                }
            } footer: {
                Text(.locationExchangeAdjustmentHint)
            }
        }
    }

    private var budgetsSection: some View {
        Section {
            LabeledContent(.locationBudget) {
                HStack {
                    NumericInputField.standard(
                        budgetInputBinding,
                        focusedField: focusedField,
                        focusID: .budget,
                        fractionDigits: 2
                    )
                    .id(inputCurrency)
                    CurrencyCodeText.standard(budgetInputCurrencyValue)
                    if !viewModel.isHomeLocation {
                        InputCurrencySwitchButton(action: onSwitchInputCurrency)
                    }
                }
            }
        } footer: {
            Text(.locationBudgetHint)
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEdit {
            Section {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(.locationDelete)
                    }
                }
            }
        }
    }

    // MARK: - Биндинги

    private var locationCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.locationCurrency },
            set: { newCurrency in
                viewModel.updateLocationCurrency(newCurrency, currentInput: inputCurrency)
            }
        )
    }

    private var rateInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateLocationToHome },
            set: { newValue in
                viewModel.updateRate(newValue, currentInput: inputCurrency)
            }
        )
    }

    private var budgetInputBinding: Binding<Double> {
        let inputSide = inputCurrency
        return Binding(
            get: {
                switch inputSide {
                case .home: viewModel.budgetHomeAmount
                case .location, .expense: viewModel.budgetLocationAmount
                }
            },
            set: { newValue in
                viewModel.updateBudget(newValue, in: inputSide)
            }
        )
    }
}

// MARK: - Превью

private struct LocationFormPreview: View {
    let preview: LocationFormPreviewData

    @State private var inputCurrency: CurrencyContext = .home
    @FocusState private var focusedField: NumericEditField?
    @FocusState private var isNameFocused: Bool

    var body: some View {
        if let viewModel = preview.viewModel {
            NavigationStack {
                LocationFormView(
                    viewModel: viewModel,
                    inputCurrency: inputCurrency,
                    focusedField: $focusedField,
                    isNameFocused: $isNameFocused,
                    onSwitchInputCurrency: {
                        focusedField = nil
                        inputCurrency = inputCurrency == .home ? .location : .home
                    },
                    onDelete: {}
                )
                .keyboardInputBar(
                    isPresented: focusedField != nil || isNameFocused,
                    onDismiss: {
                        focusedField = nil
                        isNameFocused = false
                    }
                )
            }
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
        }
    }
}

#Preview("Editing") {
    @Previewable @State var preview = LocationFormPreviewData(isEditing: true)

    LocationFormPreview(preview: preview)
}

#Preview("Creating") {
    @Previewable @State var preview = LocationFormPreviewData(isEditing: false)

    LocationFormPreview(preview: preview)
}
