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

    // MARK: - Components

    private var mainDataSection: some View {
        Section {
            TextField("location.editing.name.title", text: $viewModel.name)
            DatePicker("location.editing.startDate.title", selection: $viewModel.startDate, displayedComponents: .date)
            DatePicker("location.editing.endDate.title", selection: $viewModel.endDate, displayedComponents: .date)
        }
    }

    private var currencySection: some View {
        Section {
            Picker("location.editing.currencyCode.title", selection: locationCurrencyBinding) {
                ForEach(Currency.allCasesSortedByName) { option in
                    Text(option.localizedDisplayName)
                        .tag(option)
                }
            }
            .pickerStyle(.menu)

            LabeledContent {
                TextField(
                    "",
                    value: $viewModel.rateToBaseCurrency,
                    format: .number
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            } label: {
                Text("location.editing.exchangeRate.title")
            }
        } footer: {
            Text("location.editing.currency.footer")
        }
    }

    private var budgetsSection: some View {
        Section {
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                VStack(spacing: 8) {
                    HStack {
                        ExpenseCategoryLabel(category: category)
                        budgetInputRow(
                            currency: viewModel.baseCurrency,
                            value: budgetBinding(for: category)
                        )
                    }
                    AmountText(
                        viewModel.plannedLocalAmount(for: category),
                        currency: viewModel.currency,
                        style: .secondary
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        } header: {
            Text("location.editing.budgets.header")
        } footer: {
            HStack {
                Text("location.editing.budgets.total")
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    AmountText(
                        viewModel.plannedTotalBase,
                        currency: viewModel.baseCurrency,
                        style: .tertiary
                    )
                    AmountText(
                        viewModel.plannedTotalLocal,
                        currency: viewModel.currency,
                        style: .tertiary
                    )
                }
            }
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
                Button("location.editing.delete", role: .destructive) {
                    requestDelete()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            EventToolbarTitleView(
                title: viewModel.navigationTitle,
                eventName: viewModel.trip.name,
                startDate: viewModel.trip.startDate,
                endDate: viewModel.trip.endDate
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

    private var locationCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.currency },
            set: { viewModel.currency = $0 }
        )
    }
    
    private func budgetBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: { viewModel.budgetAmounts[category] ?? 0 },
            set: { viewModel.budgetAmounts[category] = $0 }
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
        
        return NavigationStack {
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
