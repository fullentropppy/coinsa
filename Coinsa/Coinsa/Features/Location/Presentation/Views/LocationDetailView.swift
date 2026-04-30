//
//  LocationDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

struct LocationDetailView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Состояние
    
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingLocationEdit = false
    @State private var isShowingExpenseCreate = false
    @State private var expenseToEdit: Expense?
    
    // MARK: - Зависимости
    
    private let location: Location

    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    private var viewModel: LocationDetailViewModel {
        LocationDetailViewModel (location: location)
    }
    
    // MARK: - Инициализация

    init(_ location: Location) {
        self.location = location
    }

    // MARK: - Тело View

    var body: some View {
        locationDetailForm
            .navigationTitle(viewModel.location.name)
            .navigationSubtitle(viewModel.location.trip.screenContextSubtitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingLocationEdit) {
                LocationEditView(forEdit: location) { dismiss() }
            }
            .sheet(isPresented: $isShowingExpenseCreate) {
                ExpenseEditView(
                    forCreateWith: location,
                    preselectedPaymentMethod: settingsStore.selectedPaymentMethod
                )
            }
            .sheet(item: $expenseToEdit) { expense in
                ExpenseEditView(forEdit: expense)
            }
            .safeAreaInset(edge: .bottom) {
                if !location.expenses.isEmpty {
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
            .onAppear {
                checkIfDeleted()
            }
    }
    
    // MARK: - Основной контент
    
    private var locationDetailForm: some View {
        List {
            headerSection
            locationsSection
        }
    }
    
    // MARK: - Секции
    
    private var headerSection: some View {
        Section {
            EventSummaryView(data: viewModel.eventHeaderData)
            AnalyticsNavigationLink {
                EventAnalyticsView(
                    data: viewModel.eventAnalyticsData,
                    screenContextSubtitle: location.screenContextSubtitle
                )
            }
        }
    }
    
    private var locationsSection: some View {
        Group {
            if location.expenses.isEmpty {
                emptyExpenseListContent
            } else {
                expenseListContent
            }
        }
    }
    
    // MARK: - Компоненты

    private var emptyExpenseListContent: some View {
        EmptyStateView(
            icon: Expense.primaryIcon,
            title: .expenseEmptyStateTitle,
            description: .expenseEmptyStateDescription,
            buttonLabel: .expenseAdd
        ) {
            isShowingExpenseCreate = true
        }
        .listRowBackground(Color.clear)
    }
    
    private var expenseListContent: some View {
        Group {
            GroupHeaderView(icon: Expense.primaryIcon, title: .locationExpenses)
                .listRowBackground(Color.clear)
            
            ForEach(viewModel.groupedExpenses, id: \.date) { group in
                Section(DateDisplayFormatter.formatRelative(group.date, showsTime: false)) {
                    ForEach(group.expenses) { expense in
                        NavigationLink {
                            ExpenseDetailView(expense)
                        } label: {
                            ExpenseRowView(expense)
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

    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.edit {
                isShowingLocationEdit = true
            }
        }
    }

    // MARK: - Действия

    private func requestDelete(for expenses: [Expense]) {
        deletionHandler.request(for: expenses)
    }

    private func confirmDelete() {
        withAnimation {
            deletionHandler.confirm { repository.delete($0) }
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
    
    private func checkIfDeleted() {
        if location.modelContext == nil {
            dismiss()
        }
    }
}

// MARK: - Превью

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
            LocationDetailView(location)
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
