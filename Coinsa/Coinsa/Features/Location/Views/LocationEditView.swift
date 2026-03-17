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

    init(trip: Trip, location: Location? = nil, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: LocationViewModel(
                trip: trip,
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
            .navigationTitle(viewModel.navigationTitle)
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
                        amount: viewModel.plannedLocalAmount(for: category),
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
                        amount: viewModel.plannedTotalBase,
                        currency: viewModel.baseCurrency,
                        style: .tertiary
                    )
                    AmountText(
                        amount: viewModel.plannedTotalLocal,
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
            CurrencyCodeText(currency: currency)
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
        deletionHandler.requestDelete(for: [location])
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { repository.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
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

        return LocationEditView(
            trip: trip,
            location: location,
            baseCurrency: Currency.rub
        )
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
