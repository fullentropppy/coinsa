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

    // MARK: - Computed Properties

    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

    private var localCurrencyBinding: Binding<Currency> {
        Binding(get: {
                viewModel.localCurrency
            },
            set: {
                viewModel.localCurrency = $0
            }
        )
    }
    
    private var budgetInputCurrencyValue: Currency {
        switch inputCurrency {
        case .base:
            viewModel.baseCurrency
        case .location:
            viewModel.localCurrency
        }
    }

    private func budgetInputBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: {
                switch inputCurrency {
                case .base:
                    viewModel.budgetAmounts[category] ?? 0
                case .location:
                    viewModel.plannedLocalAmount(for: category)
                }
            },
            set: { newValue in
                switch inputCurrency {
                case .base:
                    viewModel.budgetAmounts[category] = newValue
                case .location:
                    guard viewModel.rateToBaseCurrency > 0 else { return }
                    viewModel.budgetAmounts[category] = newValue * viewModel.rateToBaseCurrency
                }
            }
        )
    }
    
    private var budgetTotalValue: Double {
        switch inputCurrency {
        case .base:
            viewModel.plannedTotalBase
        case .location:
            viewModel.plannedTotalLocal
        }
    }
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: LocationEditViewModel(
                trip: trip,
                baseCurrency: baseCurrency
            )
        )
    }
    
    init(location: Location, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: LocationEditViewModel(
                location: location,
                baseCurrency: baseCurrency
            )
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                mainDataSection
                currencySection
                budgetsSection
                actionsSection
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .scrollDismissesKeyboard(.interactively)
            .interactiveDismissDisabled(viewModel.hasChanges)
            .discardConfirmationAlert(
                isPresented: $isShowingDiscardAlert,
                onConfirm: {
                    dismiss()
                }
            )
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                message: "location.delete.message",
                onConfirm: {
                    confirmDelete()
                    dismiss()
                },
                onCancel: {
                    cancelDelete()
                }
            )
        }
    }

    // MARK: - Components

    private var mainDataSection: some View {
        Section {
            TextField("location.name", text: $viewModel.name)
            DatePicker(
                "trip.startDate",
                selection: $viewModel.startDate,
                in: viewModel.trip.range,
                displayedComponents: .date
            )
            DatePicker(
                "trip.endDate",
                selection: $viewModel.endDate,
                in: viewModel.startDate...viewModel.trip.endDate,
                displayedComponents: .date
            )
        }
    }

    private var currencySection: some View {
        Section {
            Picker("location.currency", selection: localCurrencyBinding) {
                ForEach(Currency.allCasesSortedByName) { currency in
                    Text(currency.localizedDisplayName)
                        .tag(currency)
                }
            }
            .pickerStyle(.navigationLink)

            LabeledContent("location.exchangeRate") {
                HStack {
                    AmountTextField(value: $viewModel.rateToBaseCurrency)
                    CurrencyCodeText(viewModel.baseCurrency)
                        .frame(width: 40, alignment: .center)
                }
            }
        }
    }

    private var budgetsSection: some View {
        Section("location.budget") {
            Picker("", selection: $inputCurrency) {
                Text(viewModel.baseCurrency.code)
                    .tag(InputCurrency.base)
                Text(viewModel.localCurrency.code)
                    .tag(InputCurrency.location)
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
            
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                HStack {
                    ExpenseCategoryLabel(category: category)
                    Spacer()
                    AmountTextField(value: budgetInputBinding(for: category))
                    CurrencyCodeText(budgetInputCurrencyValue)
                        .frame(width: 40, alignment: .center)
                }
            }
            HStack {
                Image(systemName: "sum")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text("location.budget.total")
                Spacer()
                AmountText(
                    budgetTotalValue,
                    currency: budgetInputCurrencyValue
                )
            }
            .listRowSeparatorTint(.gray)
        }
    }

    private var actionsSection: some View {
        Section {
            if viewModel.isEditing {
                Button("location.delete", role: .destructive) {
                    requestDelete()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContextToolbarTitleView(
                title: viewModel.navigationTitle,
                subtitle: viewModel.trip.name
            )
        }
        
        ToolbarItemGroup(placement: .topBarLeading) {
            ButtonView.close {
                handleClose()
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Actions

    private func requestDelete() {
        guard let location = viewModel.location else { return }
        deletionHandler.request(for: [location])
    }

    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension LocationEditView {
    static func preview(
        withLocation: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder()
        let container = builder.buildContainer()
        let trip = builder.fetchTrip(from: container)
        var location: Location? = nil
        
        if withLocation {
            location = builder.fetchLocation(from: container)
        }
        
        return Group {
            if let location {
                LocationEditView(
                    location: location,
                    baseCurrency: Currency.defaultOption
                )
            } else {
                LocationEditView(
                    trip: trip,
                    baseCurrency: Currency.defaultOption
                )
            }
        }
        .modelContainer(container)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    LocationEditView.preview(
        withLocation: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    LocationEditView.preview(
        withLocation: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("New Location. Light - RU") {
    LocationEditView.preview(
        withLocation: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("New Location. Dark - EN") {
    LocationEditView.preview(
        withLocation: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}
