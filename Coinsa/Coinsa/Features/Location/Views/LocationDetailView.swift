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

    @Query private var locations: [Location]
    @Query private var expenses: [Expense]

    @State private var viewModel: LocationDetailViewModel?
    @State private var deletionHandler = DeletionHandler<Expense>()
    
    @State private var isShowingLocationEdit = false
    @State private var isShowingExpenseAdd = false
    
    let locationID: PersistentIdentifier

    // MARK: - Computed Properties

    private var location: Location? {
        locations.first
    }

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    // MARK: - Initialization

    init(locationID: PersistentIdentifier) {
        self.locationID = locationID

        _locations = Query(
            filter: #Predicate<Location> { $0.persistentModelID == locationID }
        )

        _expenses = Query(
            filter: #Predicate<Expense> { $0.location.persistentModelID == locationID },
            sort: [SortDescriptor(\Expense.date, order: .reverse)]
        )

        _viewModel = State(initialValue: nil)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let location, let viewModel {
                detailContent(location: location, viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            updateViewModel()
        }
        .onChange(of: locations.count) { _, _ in
            updateViewModel()
        }
    }

    // MARK: - Components

    private func detailContent(
        location: Location,
        viewModel: LocationDetailViewModel
    ) -> some View {
        Form {
            Section {
                LocationHeaderView(
                    data: viewModel.headerData,
                    showsSummary: !expenses.isEmpty
                )
            }

            Section(header: Text("location.detail.expenses.header")) {
                if expenses.isEmpty {
                    emptyExpenseListContent
                } else {
                    expenseListContent
                }
            }
        }
        .navigationTitle(viewModel.location.name)
        .navigationSubtitle(viewModel.location.trip.screenContextSubtitle)
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingLocationEdit) {
            LocationEditView(
                location: location,
                baseCurrency: settingsStore.baseCurrency
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
                HStack {
                    Spacer()
                    ButtonView.add {
                        isShowingExpenseAdd = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .deleteConfirmationAlert(
            isPresented: $deletionHandler.isShowingDeleteConfirmation,
            message: "expense.delete.message",
            onConfirm: {
                confirmDelete()
            },
            onCancel: {
                cancelDelete()
            }
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
            imageName: "creditcard",
            title: "expense.list.empty.title",
            description: "expense.list.empty.description",
            buttonLabel: "expense.list.addExpense",
            onAddAction: { isShowingExpenseAdd = true }
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.edit {
                isShowingLocationEdit = true
            }
        }
    }

    // MARK: - Actions

    private func updateViewModel() {
        guard let location else {
            viewModel = nil
            return
        }
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
        let locationID = builder.fetchLocation(from: container).persistentModelID

        return NavigationStack {
            LocationDetailView(locationID: locationID)
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
