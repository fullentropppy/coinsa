//
//  LocationEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

struct LocationEditView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @State private var viewModel: LocationEditViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: InputCurrency = .base
    @State private var isShowingDiscardAlert = false

    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Dependencies
    private let onDelete: (() -> Void)?

    // MARK: - Infrastructure
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

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
    
    // MARK: - Initializers
    init(location: Location, baseCurrency: Currency, onDelete: (() -> Void)? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(location: location, baseCurrency: baseCurrency)
        )
        self.onDelete = onDelete
    }
    
    init(trip: Trip, baseCurrency: Currency, onDelete: (() -> Void)? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(trip: trip, baseCurrency: baseCurrency)
        )
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            locationEditForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.trip.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(viewModel.hasChanges)
                .scrollDismissesKeyboard(.interactively)
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    )
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

    // MARK: Form Content
    private var locationEditForm: some View {
        Form {
            mainDataSection
            currencySection
            budgetsSection
            actionsSection
        }
    }
    
    // MARK: - Section. Main
    private var mainDataSection: some View {
        Section {
            TextField(.locationName, text: $viewModel.name)
            DatePicker(
                .locationStartDate,
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0.startOfDay }
                ),
                in: viewModel.trip.range,
                displayedComponents: .date
            )
            DatePicker(
                .locationEndDate,
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0.endOfDay }
                ),
                in: viewModel.startDate...viewModel.trip.endDate,
                displayedComponents: .date
            )
        }
    }
    
    // MARK: - Section. Currency & Payment
    private var currencySection: some View {
        Section {
            LabeledPicker(
                title: .locationCurrency,
                selection: localCurrencyBinding,
                options: Currency.allCasesSortedByName
            ) { currency in
                CurrencyLabel(currency)
            }
            
            if !viewModel.isHomeLocation {
                LabeledContent(.locationExchangeRate) {
                    ExchangeRateInputField(
                        $viewModel.rateLocalToBase,
                        currency: viewModel.baseCurrency,
                        isLoading: viewModel.isRateLoading,
                        focusedField: $focusedField,
                        focusId: .exchangeRate,
                        onRefresh: { viewModel.requestRateRefresh() }
                    )
                }
                
                LabeledContent(.locationExchangeAdjustmentPercentage) {
                    HStack {
                        NumericInputField(
                            exchangeAdjustmentInputBinding,
                            focusedField: $focusedField,
                            focusId: .exchangeAdjustmentPercentage
                        )
                        Image(systemName: "percent")
                            .fontWeight(.semibold)
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var budgetsSection: some View {
        Section {
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                HStack {
                    ExpenseCategoryLabel(category: category)
                    Spacer()
                    NumericInputField(
                        budgetInputBinding(for: category),
                        focusedField: $focusedField,
                        focusId: .budget(category.id)
                    )
                }
            }
            
            HStack {
                Image(systemName: "sum")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text(.locationBudgetTotal)
                Spacer()
                AmountText.standard(budgetTotalValue)
            }
            .listRowSeparatorTint(.gray)
        } header: {
            HStack {
                Text(.locationBudget)
                if !viewModel.isHomeLocation {
                    Spacer()
                    CurrencyCodeText(budgetInputCurrencyValue)
                    InputCurrencySwitchButton(action: switchInputCurrency)
                }
            }
        }
    }

    // MARK: - Section. Additional
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
    
    // MARK: - Toolbar
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

        ToolbarItemGroup(placement: .keyboard) {
            if focusedField != nil {
                Spacer()
                ToolbarButton.ok {
                    focusedField = nil
                }
            }
        }
    }

    // MARK: - Bindings
    private var localCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.localCurrency },
            set: { viewModel.localCurrency = $0 }
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
            get: { viewModel.exchangeAdjustmentPercentage },
            set: { newValue in
                viewModel.updateExchangeAdjustmentPercentage(newValue)
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
    
    // MARK: - Actions
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

// MARK: - Preview
private extension LocationEditView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withNewLocation: Bool = false
    ) -> some View {
        let builder = PreviewBuilder.builder()
        let container = builder.buildContainer()
        let trip = builder.fetchTrip(from: container)
        let location = withNewLocation ? nil : builder.fetchLocation(from: container)
        
        return Group {
            if let location {
                LocationEditView(location: location, baseCurrency: Currency.defaultCurrency)
            } else {
                LocationEditView(trip: trip, baseCurrency: Currency.defaultCurrency)
            }
        }
        .modelContainer(container)
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
