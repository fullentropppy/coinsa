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

    @State private var viewModel: LocationViewModel
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var inputCurrency: InputCurrency = .base

    // MARK: - Computed Properties

    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: LocationViewModel(
                trip: trip,
                baseCurrency: baseCurrency
            )
        )
    }
    
    init(location: Location, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: LocationViewModel(
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
            DatePicker("location.startDate", selection: $viewModel.startDate, displayedComponents: .date)
            DatePicker("location.endDate", selection: $viewModel.endDate, displayedComponents: .date)
        }
    }

    private var currencySection: some View {
        Section {
            Picker("location.currency", selection: localCurrencyBinding) {
                ForEach(Currency.allCasesSortedByName) { option in
                    Text(option.localizedDisplayName)
                        .tag(option)
                }
            }
            .pickerStyle(.menu)

            LabeledContent("location.exchangeRate") {
                TextField(
                    "",
                    value: $viewModel.rateToBaseCurrency,
                    format: .number
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text(
                String(
                    format: String(localized: "location.exchangeRate.hint"),
                    viewModel.baseCurrency.code,
                    viewModel.localCurrency.code
                )
            )
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var budgetsSection: some View {
        Section("location.budget") {
            LabeledContent("") {
                Picker("", selection: $inputCurrency) {
                    Text(viewModel.baseCurrency.code)
                        .tag(InputCurrency.base)
                    
                    Text(viewModel.localCurrency.code)
                        .tag(InputCurrency.location)
                }
                .pickerStyle(.segmented)
            }
            .listRowSeparator(.hidden)
            
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                HStack {
                    ExpenseCategoryLabel(category: category)
                    Spacer()
                    budgetInputRow(
                        currency: budgetInputCurrencyValue,
                        value: budgetInputBinding(for: category)
                    )
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

    private func budgetInputRow(currency: Currency, value: Binding<Double>) -> some View {
        HStack(spacing: 6) {
            TextField("", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            CurrencyCodeText(currency)
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
                dismiss()
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private var budgetInputCurrencyValue: Currency {
        switch inputCurrency {
        case .base: viewModel.baseCurrency
        case .location: viewModel.localCurrency
        }
    }

    private var budgetTotalValue: Double {
        switch inputCurrency {
        case .base: viewModel.plannedTotalBase
        case .location: viewModel.plannedTotalLocal
        }
    }
    
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
                case .location: viewModel.plannedLocalAmount(for: category)
                }
            },
            set: { newValue in
                switch inputCurrency {
                case .base: viewModel.budgetAmounts[category] = newValue
                case .location:
                    guard viewModel.rateToBaseCurrency > 0 else { return }
                    viewModel.budgetAmounts[category] = newValue * viewModel.rateToBaseCurrency
                }
            }
        )
    }

    private func requestDelete() {
        guard let location = viewModel.locationToEdit else { return }
        deletionHandler.request(for: [location])
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
