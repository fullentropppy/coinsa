//
//  LocationEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

struct LocationEditView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние
    
    @State private var viewModel: LocationEditViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: InputCurrency = .base
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
        case .local: viewModel.localCurrency
        }
    }

    private var budgetTotalValue: Double {
        switch inputCurrency {
        case .base: viewModel.plannedBaseTotal
        case .local: viewModel.plannedLocalTotal
        }
    }
    
    // MARK: - Инициализация
    
    init(forCreateWith trip: Trip, preselectedExchangeAdjustment: Double? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(
                forCreateWith: trip,
                preselectedExchangeAdjustment: preselectedExchangeAdjustment
            )
        )
        self.onDelete = nil
    }
    
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
            mainDataSection
            currencySection
            exchangeRateSection
            budgetsSection
            actionsSection
        }
    }
    
    // MARK: - Секции
    
    private var mainDataSection: some View {
        Section {
            TextField(.locationName, text: $viewModel.name)
            // ++ Отключено до реализации поддержки работы с часовыми поясами
            if false {
                LabeledPicker(
                    title: .locationTimeZone,
                    selection: majorTimeZoneBinding,
                    options: MajorTimeZone.allCasesSortedByGMT
                ) { timeZone in
                    timeZone.makeLabel()
                }
            }
            // --
            DatePicker(
                .locationStartDate,
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0 }
                ),
                in: viewModel.availableRange,
                displayedComponents: .date
            )
            DatePicker(
                .locationEndDate,
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0 }
                ),
                in: viewModel.availableRange,
                displayedComponents: .date
            )
        } footer: {
            // ++ Отключено до реализации поддержки работы с часовыми поясами
            if false {
                Text(.locationTimeZoneHint)
            }
            // --
        }
    }
    
    private var currencySection: some View {
        Section {
            LabeledPicker(
                title: .locationCurrency,
                selection: localCurrencyBinding,                
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
                LabeledContent(.locationExchangeRate(localCurrencyCode: viewModel.localCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateInputBinding,
                        currency: viewModel.baseCurrency,
                        isLoading: viewModel.isRateLoading,
                        focusedField: $focusedField,
                        focusId: .exchangeRate,
                        onRefresh: { viewModel.requestRateRefresh(for: inputCurrency) }
                    )
                }
                
                LabeledContent(.locationExchangeAdjustment) {
                    PercentInputField.standard(
                        exchangeAdjustmentInputBinding,
                        focusedField: $focusedField,
                        focusId: .exchangeAdjustment
                    )
                }
                
            } footer: {
                VStack(alignment: .leading, spacing: 10) {
                    if let adjustedExchangeRateDescription = viewModel.adjustedRateDescription {
                        Text(adjustedExchangeRateDescription)
                    }
                    
                    Text(.locationExchangeAdjustmentHint)
                }
            }
        }
    }
    
    private var budgetsSection: some View {
        Section {
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                HStack {
                    category.makeLabel()
                    Spacer()
                    NumericInputField.standard(
                        budgetInputBinding(for: category),
                        focusedField: $focusedField,
                        focusId: .budget(category.id),
                        fractionDigits: 2
                    )
                }
            }
            
            HStack {
                LabelView(style: .withIcon(title: .locationBudgetTotal, icon: "sum", iconWidth: 28))
                Spacer()
                AmountText.standard(budgetTotalValue)
            }
            .listRowSeparatorTint(.gray)
        } header: {
            HStack {
                Text(.locationBudget)
                Spacer()
                CurrencyCodeText.standard(budgetInputCurrencyValue)
                if !viewModel.isHomeLocation {
                    InputCurrencySwitchButton(action: switchInputCurrency)
                }
            }
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEdit {
            Section {
                Button(.locationDelete, role: .destructive) {
                    requestDelete()
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
    
    private var majorTimeZoneBinding: Binding<MajorTimeZone> {
        Binding(
            get: { viewModel.majorTimeZone },
            set: { viewModel.majorTimeZone = $0 }
        )
    }
    
    private var localCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.localCurrency },
            set: { newCurrency in
                viewModel.updateLocalCurrency(newCurrency, currentInput: inputCurrency)
            }
        )
    }
    
    private var rateInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateLocalToBase },
            set: { newValue in
                viewModel.updateRate(newValue, currentInput: inputCurrency)
            }
        )
    }

    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { shouldShow in
                if !shouldShow {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }
    
    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.exchangeAdjustment },
            set: { newValue in
                viewModel.updateExchangeAdjustment(newValue, currentInput: inputCurrency)
            }
        )
    }
    
    private func budgetInputBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: {
                switch inputCurrency {
                case .base: viewModel.budgetBaseAmount(for: category)
                case .local: viewModel.budgetLocalAmount(for: category)
                }
            },
            set: { newValue in
                viewModel.updateBudget(newValue, for: category, in: inputCurrency)
            }
        )
    }
    
    // MARK: - Действия
    
    private func switchInputCurrency() {
        switch inputCurrency {
        case .base: inputCurrency = .local
        case .local: inputCurrency = .base
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
