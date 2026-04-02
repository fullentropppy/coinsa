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
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettingsStore.self) private var settingsStore

    @Query private var expenses: [Expense]

    @State private var viewModel: LocationDetailViewModel?
    @State private var deletionHandler = DeletionHandler<Expense>()
    
    @State private var isShowingLocationEdit = false
    @State private var isShowingExpenseAdd = false
    
    private let location: Location

    // MARK: - Computed Properties

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    // MARK: - Initialization

    init(location: Location) {
        self.location = location
        
        let locationID = location.persistentModelID
        _expenses = Query(
            filter: #Predicate<Expense> { expense in
                expense.location.persistentModelID == locationID
            },
            sort: \Expense.date, order: .reverse
        )
        
        _viewModel = State(initialValue: nil)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let viewModel {
                detailContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            updateViewModel()
        }
    }

    // MARK: - Components

    private func detailContent(viewModel: LocationDetailViewModel) -> some View {
        Form {
            Section {
                EventHeaderView(
                    data: viewModel.eventHeaderData,
                    showsSummary: true
                )
            }

            Section("location.detail.expenses.header") {
                if expenses.isEmpty {
                    emptyExpenseListContent
                } else {
                    expenseListContent
                }
            }
        }
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
                onDelete: { dismiss() }
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
            message: "expense.delete.message",
            onConfirm: { confirmDelete() },
            onCancel: { cancelDelete() }
        )
    }
    
    private var expenseListContent: some View {
        ForEach(expenses) { expense in
            NavigationLink {
                ExpenseDetailView(expense: expense)
            } label: {
                ExpenseRowView(
                    expense: expense,
                    baseCurrency: settingsStore.baseCurrency
                )
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

    private func updateViewModel() {
        viewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: settingsStore.baseCurrency
        )
    }
    
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
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
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
