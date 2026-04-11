//
//  LocationEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

struct LocationEditView: View {
    // MARK: - Stored Properties

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: LocationEditViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: InputCurrency = .base
    @State private var isShowingDiscardAlert = false

    @FocusState private var focusedField: NumericEditField?
    
    private let onDelete: (() -> Void)?

    // MARK: - Computed Properties

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
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency, onDelete: (() -> Void)? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(trip: trip, baseCurrency: baseCurrency)
        )
        self.onDelete = onDelete
    }
    
    init(location: Location, baseCurrency: Currency, onDelete: (() -> Void)? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(location: location, baseCurrency: baseCurrency)
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
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
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
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription ?? String(localized: .errorUnknown)
                        )
                    )
                .task {
                    viewModel.loadInitialRateIfNeeded()
                }
        }
    }

    // MARK: - Content
    
    private var locationEditForm: some View {
        Form {
            mainDataSection
            currencySection
            budgetsSection
            actionsSection
        }
    }
    
    // MARK: - Sections
    
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
    
    private var currencySection: some View {
        Section {
            Picker(.locationCurrency, selection: localCurrencyBinding) {
                ForEach(Currency.allCasesSortedByName) { currency in
                    Text(currency.localized)
                        .tag(currency)
                }
            }
            .pickerStyle(.navigationLink)
            
            if !viewModel.isHomeLocation {
                LabeledContent(.locationExchangeRate) {
                    HStack {
                        NumericInputField(
                            $viewModel.rateLocalToBase,
                            focusedField: $focusedField,
                            focusId: .exchangeRate,
                            fractionDigits: 4,
                        )
                        .loadingState(viewModel.isRateLoading)
                        CurrencyCodeText(viewModel.baseCurrency)

                        ExchangeRateRefreshButton(
                            isLoading: viewModel.isRateLoading,
                            onRefresh: viewModel.requestRateRefresh
                        )
                    }
                }
            }
        }
    }
    
    private var budgetsSection: some View {
        Section(.locationBudget) {
            if !viewModel.isHomeLocation {
                Picker("", selection: $inputCurrency) {
                    Text(viewModel.baseCurrency.code)
                        .tag(InputCurrency.base)
                    Text(viewModel.localCurrency.code)
                        .tag(InputCurrency.local)
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)
            }
            
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                HStack {
                    ExpenseCategoryLabel(category: category)
                    Spacer()
                    NumericInputField(
                        budgetInputBinding(for: category),
                        focusedField: $focusedField,
                        focusId: .budget(category.id)
                    )
                    CurrencyCodeText(budgetInputCurrencyValue)
                }
            }
            
            HStack {
                Image(systemName: "sum")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text(.locationBudgetTotal)
                Spacer()
                AmountText.standard(budgetTotalValue)
                CurrencyCodeText(budgetInputCurrencyValue)
            }
            .listRowSeparatorTint(.gray)
        }
        
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEditing {
            Section {
                Button(.locationDelete, role: .destructive) {
                    requestDelete()
                }
            }
        }
    }
    
    // MARK: - Components

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

// MARK: - Previews

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
