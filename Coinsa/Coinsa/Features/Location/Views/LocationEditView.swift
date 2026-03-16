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

    private var repository: LocationRepository {
        LocationRepository(context: context)
    }

    // MARK: - Initialization

    init(trip: Trip, location: Location? = nil, baseCurrencyOption: CurrencyOption) {
        _viewModel = State(
            initialValue: LocationViewModel(
                trip: trip,
                location: location,
                baseCurrencyOption: baseCurrencyOption
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
                            currencyOption: viewModel.baseCurrencyOption,
                            value: budgetBinding(for: category)
                        )
                    }
                    AmountText(
                        amount: viewModel.plannedLocalAmount(for: category),
                        currencyOption: viewModel.currencyOption,
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
                        currencyOption: viewModel.baseCurrencyOption,
                        style: .tertiary
                    )
                    AmountText(
                        amount: viewModel.plannedTotalLocal,
                        currencyOption: viewModel.currencyOption,
                        style: .tertiary
                    )
                }
            }
        }
    }

    private func budgetInputRow(currencyOption: CurrencyOption, value: Binding<Double>) -> some View {
        HStack(spacing: 6) {
            TextField("", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            CurrencyCodeText(currencyOption: currencyOption)
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

    private var locationCurrencyBinding: Binding<CurrencyOption> {
        Binding(
            get: { viewModel.currencyOption },
            set: { viewModel.currencyOption = $0 }
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
        deletionHandler.requestDelete(items: [location])
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
            baseCurrencyOption: CurrencyOption.rub
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
