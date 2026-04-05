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
            initialValue: LocationEditViewModel(
                trip: trip,
                baseCurrency: baseCurrency
            )
        )
        self.onDelete = onDelete
    }
    
    init(location: Location, baseCurrency: Currency, onDelete: (() -> Void)? = nil) {
        _viewModel = State(
            initialValue: LocationEditViewModel(
                location: location,
                baseCurrency: baseCurrency
            )
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
                    onConfirm: {
                        dismiss()
                    }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    message: .locationDeleteMessage,
                    onConfirm: {
                        confirmDelete()
                    },
                    onCancel: {
                        cancelDelete()
                    }
                )
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
                        AmountTextField($viewModel.rateLocalToBase, fractionDigits: 4)
                        CurrencyCodeText(viewModel.baseCurrency)
                            .frame(width: 40, alignment: .center)
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
                    AmountTextField(budgetInputBinding(for: category))
                    CurrencyCodeText(budgetInputCurrencyValue)
                        .frame(width: 40, alignment: .center)
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
                    .frame(width: 40, alignment: .center)
            }
            .listRowSeparatorTint(.gray)
        }
    }

    private var actionsSection: some View {
        Section {
            if viewModel.isEditing {
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
            ToolbarButtonView.close {
                handleClose()
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Bindings
    
    private var localCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.localCurrency },
            set: { viewModel.localCurrency = $0 }
        )
    }
    
    private func budgetInputBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: {
                switch inputCurrency {
                case .base: viewModel.budgetAmounts[category] ?? 0
                case .local: viewModel.plannedLocalAmount(for: category)
                }
            },
            set: { newValue in
                switch inputCurrency {
                case .base: viewModel.budgetAmounts[category] = newValue
                case .local:
                    guard viewModel.rateLocalToBase > 0 else { return }
                    viewModel.budgetAmounts[category] = newValue * viewModel.rateLocalToBase
                }
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
        guard let location = viewModel.location else { return }
        deletionHandler.request(for: [location])
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
        withLocation: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder()
        let container = builder.buildContainer()
        let trip = builder.fetchTrip(from: container)
        let location = withLocation ? builder.fetchLocation(from: container) : nil
        
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

#Preview("Light - RU") {
    LocationEditView.makePreview(
        withLocation: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    LocationEditView.makePreview(
        withLocation: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("New Location. Light - RU") {
    LocationEditView.makePreview(
        withLocation: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("New Location. Dark - EN") {
    LocationEditView.makePreview(
        withLocation: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}
