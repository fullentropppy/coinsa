//
//  LocationDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

struct LocationDetailView: View {
    // MARK: - Stored Properties

    @Environment(AppSettingsStore.self) private var settingsStore

    @State private var isShowingLocationEdit = false

    let location: Location

    // MARK: - Computed Properties

    private var viewModel: LocationDetailViewModel {
        LocationDetailViewModel(
            location: location,
            baseCurrencyOption: settingsStore.baseCurrencyOption
        )
    }

    private var shouldShowAddButton: Bool {
        !location.expenses.isEmpty
    }

    // MARK: - Body

    var body: some View {
        List {
            Section {
                LocationHeaderView(data: viewModel.headerData)
            }

            Section {
                ExpenseListView(
                    locationID: location.persistentModelID,
                    onAddExpense: { handleAddExpense() },
                    presentation: .embedded
                )
            }
        }
        .navigationTitle(location.name)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingLocationEdit) {
            LocationEditView(
                trip: location.trip,
                location: location,
                baseCurrencyOption: settingsStore.baseCurrencyOption
            )
        }
        .overlay(alignment: .bottomTrailing) {
            if shouldShowAddButton {
                ButtonView.add {
                    handleAddExpense()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: - Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.edit {
                isShowingLocationEdit = true
            }
        }
    }

    // MARK: - Actions

    private func handleAddExpense() { }
}

// MARK: - Previews

private extension LocationDetailView {
    static func preview(
        withExpenses: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withExpenses(withExpenses)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let location = builder.fetchLocation(from: container)

        return NavigationStack {
            LocationDetailView(location: location)
                .modelContainer(container)
                .environment(settingsStore)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    LocationDetailView.preview(
        withExpenses: true,
        locale: PreviewLocale.ru.locale,
        colorScheme: .light
    )
}

#Preview("Dark - EN") {
    LocationDetailView.preview(
        withExpenses: true,
        locale: PreviewLocale.en.locale,
        colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    LocationDetailView.preview(
        withExpenses: false,
        locale: PreviewLocale.ru.locale,
        colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    LocationDetailView.preview(
        withExpenses: false,
        locale: PreviewLocale.en.locale,
        colorScheme: .dark
    )
}
