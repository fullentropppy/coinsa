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
    @State private var deletionHandler = DeletionHandler<Location>(
        messageKey: "location.deletionConfirmation.message.single"
    )

    // MARK: - Computed Properties

    private var store: LocationStore {
        LocationStore(context: context)
    }

    // MARK: - Initialization

    init(trip: Trip, location: Location? = nil) {
        _viewModel = State(
            initialValue: LocationViewModel(
                trip: trip,
                location: location
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
            .alert("location.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
                Button("location.list.deletionConfirmation.delete", role: .destructive) {
                    confirmDelete()
                    dismiss()
                }
                Button("common.cancel", role: .cancel) {
                    cancelDelete()
                }
            } message: {
                Text(deletionHandler.confirmationMessage)
            }
            .toolbar {
                toolbarContent
            }
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
                ForEach(CurrencyOption.allCasesSortedByName) { option in
                    Text(option.localizedDisplayName)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)

            LabeledContent {
                TextField(
                    "",
                    value: $viewModel.exchangeRateLocationToBaseCurrency,
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
            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: category.sfSymbolName)
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text(category.localizedDisplayName)
                        Spacer()
                    }
                    HStack(spacing: 12) {
                        budgetInputRow(
                            currencyCode: viewModel.baseCurrencyCode,
                            value: budgetBinding(for: category)
                        )
                        budgetInputRow(
                            currencyCode: viewModel.locationCurrencyCode.uppercased(),
                            value: budgetLocalBinding(for: category)
                        )
                    }
                }
            }
        } header: {
            Text("location.editing.budgets.header")
        } footer: {
            HStack {
                Text("location.editing.budgets.total")
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(plannedTotalBase, format: .currency(code: viewModel.baseCurrencyCode))
                    Text(plannedTotalLocal, format: .currency(code: viewModel.locationCurrencyCode))
                }
            }
        }
    }

    private func budgetInputRow(currencyCode: String, value: Binding<Double>) -> some View {
        HStack(spacing: 6) {
            TextField("", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text(currencyCode)
                .foregroundStyle(.secondary)
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
                viewModel.save(using: store)
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func budgetBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: { viewModel.budgetAmounts[category] ?? 0 },
            set: { viewModel.budgetAmounts[category] = $0 }
        )
    }

    private func budgetLocalBinding(for category: ExpenseCategory) -> Binding<Double> {
        Binding(
            get: {
                let rate = viewModel.exchangeRateLocationToBaseCurrency
                guard rate > 0 else { return 0 }
                return (viewModel.budgetAmounts[category] ?? 0) / rate
            },
            set: { newValue in
                let rate = viewModel.exchangeRateLocationToBaseCurrency
                viewModel.budgetAmounts[category] = max(0, newValue * rate)
            }
        )
    }

    private var plannedTotalBase: Double {
        viewModel.budgetAmounts.values.reduce(0, +)
    }

    private var plannedTotalLocal: Double {
        let rate = viewModel.exchangeRateLocationToBaseCurrency
        guard rate > 0 else { return 0 }
        return plannedTotalBase / rate
    }

    private var locationCurrencyBinding: Binding<CurrencyOption> {
        Binding(
            get: { CurrencyOption.from(code: viewModel.locationCurrencyCode) },
            set: { viewModel.locationCurrencyCode = $0.code }
        )
    }

    private func requestDelete() {
        guard let location = viewModel.locationToEdit else { return }
        deletionHandler.requestDelete(items: [location])
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { store.delete($0) }
        dismiss()
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private struct previewData {
    let container: ModelContainer
    let trip: Trip
    let location: Location

    init() {
        let builder = PreviewBuilder.builder().withBudgets(true).withExpenses(false)
        self.container = builder.buildContainer()
        self.trip = builder.fetchTrip(from: container)
        self.location = builder.fetchLocation(from: container)
    }
}

#Preview("Light - RU") {
    let data = previewData()
    LocationEditView(
        trip: data.trip,
        location: data.location
    )
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    let data = previewData()
    LocationEditView(
        trip: data.trip,
        location: data.location
    )
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty item") {
    let data = previewData()
    LocationEditView(trip: data.trip)
        .modelContainer(data.container)
}
