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
    @State private var isShowingExpenseCreate = false
    @State private var expenseToEdit: Expense?
    
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
    
    private var groupedExpenses: [(date: Date, expenses: [Expense])] {
        let today = Date().startOfDay
        let yesterday = today.adding(days: -1)
        
        var grouped: [Date: [Expense]] = [:]
        
        for expense in expenses {
            grouped[expense.date.startOfDay, default: []].append(expense)
        }
        
        for (day, _) in grouped {
            grouped[day] = grouped[day]?.sorted { $0.date > $1.date }
        }
        
        var result: [(date: Date, expenses: [Expense])] = []
        
        if let todayExpenses = grouped[today] {
            result.append((date: today, expenses: todayExpenses))
        }
        
        if let yesterdayExpenses = grouped[yesterday] {
            result.append((date: yesterday, expenses: yesterdayExpenses))
        }
        
        let otherDates = grouped.keys
            .filter { $0 != today && $0 != yesterday }
            .sorted(by: >)
        
        for date in otherDates {
            if let expensesForDate = grouped[date] {
                result.append((date: date, expenses: expensesForDate))
            }
        }
        
        return result
    }
    
    // MARK: - Initialization

    init(location: Location) {
        let locationID = location.persistentModelID
        _expenses = Query(
            filter: #Predicate<Expense> { expense in
                expense.location.persistentModelID == locationID
            }
        )
        self.location = location
    }

    // MARK: - Body

    var body: some View {
        locationDetailForm
            .navigationTitle(viewModel.location.name)
            .navigationSubtitle(viewModel.location.trip.screenContextSubtitle)
            .toolbarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $isShowingExpenseCreate) {
                ExpenseEditView(location: location, baseCurrency: settingsStore.baseCurrency)
            }
            .sheet(item: $expenseToEdit) { expense in
                ExpenseEditView(expense: expense, baseCurrency: settingsStore.baseCurrency)
            }
            .safeAreaInset(edge: .bottom) {
                if !expenses.isEmpty {
                    PrimaryAddButton(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingExpenseCreate = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                title: .expenseDeleteTitle,
                message: .expenseDeleteMessage,
                onConfirm: { confirmDelete() },
                onCancel: { cancelDelete() }
            )
    }

    // MARK: - Content
    
    private var locationDetailForm: some View {
        List {
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
        Group {
            if expenses.isEmpty {
                emptyExpenseListContent
            } else {
                expenseListContent
            }
        }
    }
    
    // MARK: - Components

    private var expenseListContent: some View {
        Group {
            GroupHeaderView(title: .locationExpenses, icon: Expense.primaryIcon)
                .listRowBackground(Color.clear)
            
            ForEach(Array(groupedExpenses.enumerated()), id: \.offset) { _, group in
                Section(DateDisplayFormatter.formatRelative(group.date, showsTime: false)) {
                    ForEach(group.expenses) { expense in
                        NavigationLink {
                            ExpenseDetailView(expense: expense)
                        } label: {
                            ExpenseRowView(expense: expense, baseCurrency: settingsStore.baseCurrency)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            SwipeActions(
                                onDelete: { requestDelete(for: [expense]) },
                                onEdit: { expenseToEdit = expense }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var emptyExpenseListContent: some View {
        EmptyStateView(
            imageName: Expense.primaryIcon,
            title: .expenseEmptyStateTitle,
            description: .expenseEmptyStateDescription,
            buttonLabel: .expenseAdd
        ) {
            isShowingExpenseCreate = true
        }
        .listRowBackground(Color.clear)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.edit {
                isShowingLocationEdit = true
            }
        }
    }

    // MARK: - Actions

    private func requestDelete(for expenses: [Expense]) {
        deletionHandler.request(for: expenses)
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
