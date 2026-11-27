//
//  TripGeneralExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import SwiftUI
import SwiftData

/// Сводка и список общих трат с привычными редакторами и подтверждением удаления.
struct TripGeneralExpensesView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние

    @State private var isShowingCreate = false
    @State private var isShowingAnalytics = false
    @State private var expenseToEdit: Expense?
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingDeletionError = false

    private let trip: Trip

    private var isTripAvailable: Bool {
        !trip.isDeleted && trip.modelContext === context
    }

    private var viewModel: TripGeneralExpensesViewModel {
        TripGeneralExpensesViewModel(trip: trip)
    }

    // MARK: - Инициализация

    /// Открывает общие траты переданной поездки без повторного запроса родительской модели.
    /// - Parameter trip: Поездка из текущего контекста.
    init(_ trip: Trip) {
        self.trip = trip
    }

    // MARK: - Тело View

    var body: some View {
        Group {
            if isTripAvailable {
                content
            } else {
                Color.clear
            }
        }
        .onChange(of: isTripAvailable, initial: true) { _, available in
            if !available {
                isShowingCreate = false
                isShowingAnalytics = false
                expenseToEdit = nil
                dismiss()
            }
        }
    }

    private var content: some View {
        List {
            Section {
                EventSummaryView(data: viewModel.summaryData, showsHeader: false)
                HStack {
                    DetailNavigationButton.trip {
                        dismiss()
                    }
                    if !viewModel.expenses.isEmpty {
                        DetailNavigationButton.analytics {
                            isShowingAnalytics = true
                        }
                    }
                }
            }
            if viewModel.expenses.isEmpty {
                EmptyStateView(
                    icon: Expense.primaryIcon,
                    title: .tripGeneralExpensesEmptyStateTitle,
                    description: .tripGeneralExpensesEmptyStateDescription,
                    buttonLabel: .expenseAdd
                ) {
                    isShowingCreate = true
                }
                .listRowBackground(Color.clear)
            } else {
                GroupHeader(
                    icon: Expense.primaryIcon,
                    title: .tripGeneralExpensesExpenses,
                    itemCount: viewModel.expenses.count
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
                                    onDelete: { deletionHandler.request(for: [expense]) },
                                    onEdit: { expenseToEdit = expense }
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text(.tripGeneralExpensesNavigationTitle))
        .navigationSubtitle(trip.screenContextSubtitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingAnalytics) { [trip] in
            AnalyticsDestinationView { [trip] in
                EventAnalyticsView(
                    data: TripGeneralExpensesViewModel(trip: trip).eventAnalyticsData,
                    navigationTitle: .analyticsNavigationTitleGeneralExpenses,
                    screenContextSubtitle: trip.screenContextSubtitle
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.expenses.isEmpty {
                PrimaryAddButton(isOnLeft: settingsStore.isFloatingButtonOnLeft) {
                    isShowingCreate = true
                }
            }
        }
        .sheet(isPresented: $isShowingCreate) {
            ExpenseEditorView(
                forCreateWith: trip,
                preselectedPaymentMethod: settingsStore.selectedPaymentMethod,
                exchangeAdjustment: settingsStore.exchangeAdjustment
            )
        }
        .sheet(item: $expenseToEdit) { expense in
            ExpenseEditorView(forEdit: expense)
        }
        .deleteConfirmationAlert(
            isPresented: $deletionHandler.isShowingDeleteConfirmation,
            title: .expenseDeleteTitle,
            message: .expenseDeleteMessage,
            onConfirm: delete,
            onCancel: { deletionHandler.cancel() }
        )
        .notificationAlert(
            isPresented: $isShowingDeletionError,
            title: .expenseStorageErrorTitle,
            message: .expenseStorageErrorDeleteMessage,
            isError: true
        )
    }

    // MARK: - Действия

    private func delete() {
        do {
            try ExpenseRepository(context: context).delete(deletionHandler.itemsPendingDeletion)
            deletionHandler.cancel()
        } catch {
            isShowingDeletionError = true
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData(includeLocations: true, includeExpenses: true)
    NavigationStack {
        TripGeneralExpensesView(preview.trip)
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData()
    NavigationStack {
        TripGeneralExpensesView(preview.trip)
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
