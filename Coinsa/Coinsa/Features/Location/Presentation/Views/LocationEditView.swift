//
//  LocationEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

/// Экран создания/редактирования локации.
struct LocationEditView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние
    
    @State private var viewModel: LocationEditViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: CurrencyContext = .base
    @State private var isShowingDiscardAlert = false
    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Зависимости
    
    private let onDelete: (() -> Void)?

    // MARK: - Инфраструктура
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

    // MARK: - Вычисляемые свойства
    
    private var budgetInputCurrencyValue: Currency {
        switch inputCurrency {
        case .base: viewModel.baseCurrency
        case .location, .expense: viewModel.locationCurrency
        }
    }

    private var budgetTotalValue: Double {
        switch inputCurrency {
        case .base: viewModel.budgetBaseAmount
        case .location, .expense: viewModel.budgetLocationAmount
        }
    }
    
    // MARK: - Инициализация
    
    /// Создает экран для новой локации.
    /// - Parameters:
    ///   - trip: Родительская поездка.
    ///   - preselectedExchangeAdjustment: Предустановленная корректировка курса.
    init(forCreateWith trip: Trip, preselectedExchangeAdjustment: Double? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(
                forCreateWith: trip,
                preselectedExchangeAdjustment: preselectedExchangeAdjustment
            )
        )
        self.onDelete = nil
    }
    
    /// Создает экран для редактирования существующей локации.
    /// - Parameters:
    ///   - location: Редактируемая локация.
    ///   - onDelete: Действие после удаления.
    init(forEdit location: Location, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: LocationEditViewModel(forEdit: location))
        self.onDelete = onDelete
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationStack {
            locationEditForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.trip.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    ),
                    isError: true
                )
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .locationDeleteTitle,
                    message: .locationDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete() }
                )
                .task {
                    viewModel.loadInitialRateIfNeeded()
                }
        }
    }

    // MARK: Основной контекнт
    
    private var locationEditForm: some View {
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
            TextField(.locationName, text: $viewModel.name)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
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
                options: Currency.allCasesSortedByName,
                disabled: viewModel.hasExpenses
            ) { currency in
                currency.makeLabel()
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
                        currency: viewModel.baseCurrency,
                        isLoading: viewModel.isRateLoading,
                        focusedField: $focusedField,
                        focusId: .exchangeRate,
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
                        focusedField: $focusedField,
                        focusId: .exchangeAdjustment
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
                        focusedField: $focusedField,
                        focusId: .budget,
                        fractionDigits: 2
                    )
                    CurrencyCodeText.standard(budgetInputCurrencyValue)
                    if !viewModel.isHomeLocation {
                        InputCurrencySwitchButton(action: switchInputCurrency)
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
                    requestDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(.locationDelete)
                    }
                }
            }
        }
    }
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButton.close {
                handleClose()
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.ok {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
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
            get: { viewModel.rateLocationToBase },
            set: { newValue in
                viewModel.updateRate(newValue, currentInput: inputCurrency)
            }
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
    
    private var budgetInputBinding: Binding<Double> {
        Binding(
            get: {
                budgetTotalValue
            },
            set: { newValue in
                viewModel.updateBudget(newValue, in: inputCurrency)
            }
        )
    }
    
    // MARK: - Действия
    
    private func switchInputCurrency() {
        switch inputCurrency {
        case .base: inputCurrency = .location
        case .location, .expense: inputCurrency = .base
        }
    }
    
    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }
    
    private func requestDelete() {
        if let location = viewModel.location {
            deletionHandler.request(for: [location])
        }
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
        dismiss()
        onDelete?()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

private extension LocationEditView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withNewLocation: Bool = false
    ) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
       
        return Group {
            if withNewLocation {
                return LocationEditView(forCreateWith: trip)
            } else {
                let location = builder.getLocation(from: data)
                return LocationEditView(forEdit: location)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Edit. Light - RU") {
    LocationEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Edit. Dark - EN") {
    LocationEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Create. Light - RU") {
    LocationEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withNewLocation: true)
}

#Preview("Create. Dark - EN") {
    LocationEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withNewLocation: true)
}
