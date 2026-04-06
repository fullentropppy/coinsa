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

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    
    @Query private var expenses: [Expense]

    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingLocationEdit = false
    @State private var isShowingExpenseAdd = false
    
    private let location: Location

    // MARK: - Computed Properties

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    private var viewModel: LocationDetailViewModel {
        LocationDetailViewModel (
            location: location,
            baseCurrency: settingsStore.baseCurrency
        )
    }
    
    // MARK: - Initialization

    init(location: Location) {
        let locationID = location.persistentModelID
        _expenses = Query(
            filter: #Predicate<Expense> { expense in
                expense.location.persistentModelID == locationID
            },
            sort: \Expense.date, order: .reverse
        )
        self.location = location
    }

    // MARK: - Body

    var body: some View {
        locationDetailForm
            .navigationTitle(viewModel.location.name)
            .navigationSubtitle(viewModel.location.trip.screenContextSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingLocationEdit) {
                LocationEditView(
                    location: location,
                    baseCurrency: settingsStore.baseCurrency,
                    onDelete: {
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $isShowingExpenseAdd) {
                ExpenseEditView(
                    location: location,
                    baseCurrency: settingsStore.baseCurrency
                )
            }
            .safeAreaInset(edge: .bottom) {
                if !expenses.isEmpty {
                    PrimaryAddButtonView(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingExpenseAdd = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                message: .expenseDeleteMessage,
                onConfirm: { confirmDelete() },
                onCancel: { cancelDelete() }
            )
    }

    // MARK: - Content
    
    private var locationDetailForm: some View {
        Form {
            headerSection
            locationsSection
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        Section {
            EventSummaryView(data: viewModel.eventHeaderData)
        }
    }
    
    private var locationsSection: some View {
        Section(.locationExpenses) {
            if expenses.isEmpty {
                emptyExpenseListContent
            } else {
                expenseListContent
            }
        }
    }
    
    // MARK: - Components

    private var expenseListContent: some View {
        ForEach(expenses) { expense in
            NavigationLink {
                ExpenseDetailView(expense: expense)
            } label: {
                ExpenseRowView(expense: expense, baseCurrency: settingsStore.baseCurrency)
            }
        }
        .onDelete(perform: requestDelete)
    }

    private var emptyExpenseListContent: some View {
        EmptyStateView(
            imageName: Expense.primaryIcon,
            title: .expenseEmptyStateTitle,
            description: .expenseEmptyStateDescription,
            buttonLabel: .expenseAdd
        ) {
            isShowingExpenseAdd = true
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButtonView.edit {
                isShowingLocationEdit = true
            }
        }
    }

    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.request(for: offsets.map { expenses[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirm { context.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension LocationDetailView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withExpenses: Bool = true
    ) -> some View {
        let builder = PreviewBuilder.builder().withExpenses(withExpenses)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let location = builder.fetchLocation(from: container)

        return NavigationStack {
            LocationDetailView(location: location)
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    LocationDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    LocationDetailView.makePreview(locale: PreviewLocale.en, colorScheme: .dark
    )
}

#Preview("No expenses. Light - RU") {
    LocationDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withExpenses: false)
}

#Preview("No expenses. Dark - EN") {
    LocationDetailView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withExpenses: false)
}
