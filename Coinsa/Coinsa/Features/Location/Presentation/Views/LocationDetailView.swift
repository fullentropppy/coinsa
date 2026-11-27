//
//  LocationDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import SwiftUI
import SwiftData

/// Детальный экран локации.
struct LocationDetailView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние
    
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingDeletionError = false
    @State private var isShowingLocationDeleteConfirmation = false
    @State private var isShowingLocationDeletionError = false
    @State private var isShowingLocationEdit = false
    @State private var isShowingExpenseCreate = false
    @State private var expenseToEdit: Expense?
    @State private var isShowingBudgetTransfer = false
    @State private var transferSuccessMessage: LocalizedStringResource?
    @State private var isShowingTransferSuccess = false
    @State private var tripToShow: Trip?
    @State private var isShowingAnalytics = false
    
    // MARK: - Зависимости
    
    private let location: Location
    private let parentTripID: UUID?

    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    private var viewModel: LocationDetailViewModel {
        LocationDetailViewModel(location: location)
    }
    
    // MARK: - Инициализация

    /// Создает экран локации с возможностью возврата к поездке, из которой она открыта.
    /// - Parameters:
    ///   - location: Локация для отображения.
    ///   - parentTripID: Идентификатор поездки на предыдущем экране текущего стека, если она есть.
    init(_ location: Location, parentTripID: UUID? = nil) {
        self.location = location
        self.parentTripID = parentTripID
    }

    // MARK: - Тело View

    var body: some View {
        Group {
            if !location.isDeleted, location.modelContext === context {
                locationDetailContent
            } else {
                Color.clear
            }
        }
        .onAppear {
            checkIfDeleted()
        }
    }

    private var locationDetailContent: some View {
        locationDetailForm
            .navigationTitle(viewModel.navigationTitle)
            .navigationSubtitle(viewModel.navigationSubtitle)
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(item: $tripToShow) { trip in
                TripDetailView(trip)
            }
            .navigationDestination(isPresented: $isShowingAnalytics) { [location] in
                AnalyticsDestinationView { [location] in
                    EventAnalyticsView(
                        data: LocationDetailViewModel(location: location).eventAnalyticsData,
                        navigationTitle: .analyticsNavigationTitleLocation,
                        screenContextSubtitle: location.screenContextSubtitle
                    )
                }
            }
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingLocationEdit) {
                LocationEditorView(forEdit: location) { dismiss() }
            }
            .sheet(isPresented: $isShowingExpenseCreate) {
                ExpenseEditorView(
                    forCreateWith: location,
                    preselectedPaymentMethod: settingsStore.selectedPaymentMethod
                )
            }
            .sheet(item: $expenseToEdit) { expense in
                ExpenseEditorView(forEdit: expense)
            }
            .sheet(isPresented: $isShowingBudgetTransfer, onDismiss: showTransferSuccessIfNeeded) {
                LocationBudgetTransferView(source: location) { destinationName in
                    transferSuccessMessage = .locationBudgetTransferSuccessMessage(
                        destinationName: destinationName
                    )
                }
            }
            .notificationAlert(
                isPresented: $isShowingTransferSuccess,
                title: "",
                message: transferSuccessMessage ?? .errorUnknownMessage
            )
            .notificationAlert(
                isPresented: $isShowingDeletionError,
                title: .expenseStorageErrorTitle,
                message: .expenseStorageErrorDeleteMessage,
                isError: true
            )
            .safeAreaInset(edge: .bottom) {
                if location.hasExpenses {
                    PrimaryAddButton(isOnLeft: settingsStore.isFloatingButtonOnLeft) {
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
            .deleteConfirmationAlert(
                isPresented: $isShowingLocationDeleteConfirmation,
                title: .locationDeleteTitle,
                message: .locationDeleteMessage,
                onConfirm: confirmLocationDelete,
                onCancel: { isShowingLocationDeleteConfirmation = false }
            )
            .notificationAlert(
                isPresented: $isShowingLocationDeletionError,
                title: .locationStorageErrorTitle,
                message: .locationStorageErrorDeleteMessage,
                isError: true
            )
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
            HStack {
                if let trip = location.trip, !trip.isDeleted, trip.modelContext === context {
                    DetailNavigationButton.trip {
                        if trip.id == parentTripID {
                            dismiss()
                        } else {
                            tripToShow = trip
                        }
                    }
                }
                if location.hasExpenses {
                    DetailNavigationButton.analytics {
                        isShowingAnalytics = true
                    }
                }
            }
        }
    }
    
    private var locationsSection: some View {
        Group {
            if location.hasExpenses {
                expenseListContent
            } else {
                emptyExpenseListContent
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
            GroupHeader(
                icon: Expense.primaryIcon,
                title: .locationExpenses,
                itemCount: location.expensesCount
            )
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
            DetailActionsMenu(title: .locationActions, onEdit: {
                isShowingLocationEdit = true
            }, onDelete: {
                isShowingLocationDeleteConfirmation = true
            }) {
                if LocationBudgetTransferViewModel.canTransfer(from: location) {
                    Button {
                        haptics.trigger(.tap)
                        transferSuccessMessage = nil
                        isShowingBudgetTransfer = true
                    } label: {
                        Label(.locationBudgetTransferAction, systemImage: AppSymbols.arrowForwardToLine)
                    }
                }
            }
        }
    }

    // MARK: - Действия

    private func confirmLocationDelete() {
        do {
            try LocationRepository(context: context).delete(location)
            dismiss()
        } catch {
            isShowingLocationDeletionError = true
        }
    }

    private func showTransferSuccessIfNeeded() {
        isShowingTransferSuccess = transferSuccessMessage != nil
    }

    private func requestDelete(for expenses: [Expense]) {
        deletionHandler.request(for: expenses)
    }

    private func confirmDelete() {
        do {
            try withAnimation {
                try repository.delete(deletionHandler.itemsPendingDeletion)
            }
            deletionHandler.cancel()
        } catch {
            isShowingDeletionError = true
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

#Preview("With Expenses") {
    @Previewable @State var preview = TripPreviewData(includeLocations: true, includeExpenses: true)

    if let location = preview.trip.locations?.first {
        NavigationStack {
            LocationDetailView(location)
        }
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
    }
}

#Preview("Without Expenses") {
    @Previewable @State var preview = TripPreviewData(includeLocations: true)

    if let location = preview.trip.locations?.first {
        NavigationStack {
            LocationDetailView(location)
        }
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
    }
}
