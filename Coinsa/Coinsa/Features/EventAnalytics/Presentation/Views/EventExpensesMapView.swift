//
//  EventExpensesMapView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftData
import SwiftUI

/// Полноэкранная карта мест трат с переходом к деталям и выбором трат в одной точке.
struct EventExpensesMapView: View {
    // MARK: - Окружение

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние

    @State private var selectedExpenseID: UUID?
    @State private var selectedGroup: ExpenseMapGroup?
    @State private var fitRequest = 0
    @State private var cameraState = ExpenseMapCameraState()

    // MARK: - Свойства

    @Query private var expenses: [Expense]
    let screenContextSubtitle: String

    private var items: [ExpenseMapItem] {
        ExpenseMapItem.items(for: expenses)
    }

    // MARK: - Инициализация

    /// Создает карту с наблюдаемой выборкой переданных трат и подзаголовком события.
    init(expenses: [Expense], screenContextSubtitle: String) {
        let expenseIDs = expenses.map(\.id)
        _expenses = Query(filter: #Predicate<Expense> { expense in
            expenseIDs.contains(expense.id)
        })
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            mapContent
                .navigationTitle(.analyticsExpensePlaces)
                .navigationSubtitle(screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ToolbarButton.close {
                            dismiss()
                        }
                    }
                }
                .navigationDestination(item: $selectedExpenseID) { id in
                    if let expense = availableExpense(with: id) {
                        ExpenseDetailView(expense)
                    }
                }
        }
        .sheet(item: $selectedGroup) { group in
            ExpenseMapGroupView(
                expenses: expenses,
                expenseIDs: group.expenseIDs,
                screenContextSubtitle: screenContextSubtitle
            )
        }
        .onChange(of: Set(expenses.map(\.id))) {
            if let selectedExpenseID, availableExpense(with: selectedExpenseID) == nil {
                self.selectedExpenseID = nil
            }
        }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        GeometryReader { geometry in
            ClusteredExpensesMap(
                items: items,
                contentInsets: geometry.safeAreaInsets,
                fitRequest: fitRequest,
                cameraState: cameraState,
                onSelectExpense: { id in
                    guard availableExpense(with: id) != nil else { return }
                    selectedExpenseID = id
                },
                onSelectGroup: { ids in
                    selectedGroup = ExpenseMapGroup(expenseIDs: ids)
                }
            )
            .ignoresSafeArea()
        }
        .overlay {
            if items.isEmpty {
                EmptyStateView(icon: "map", title: .analyticsExpensePlacesEmptyState)
                    .background(.regularMaterial)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            mapBottomBar
        }
    }

    private var mapBottomBar: some View {
        HStack {
            if !settingsStore.isFloatingButtonOnLeft {
                Spacer()
            }

            Button {
                fitRequest += 1
            } label: {
                Image(systemName: "scope")
            }
            .disabled(items.isEmpty)
            .padding(MapLayout.buttonPadding)
            .contentShape(Circle())
            .glassEffect(.regular.interactive(), in: .circle)

            if settingsStore.isFloatingButtonOnLeft {
                Spacer()
            }
        }
        .padding(.horizontal, MapLayout.bottomBarInset)
        .padding(.bottom, MapLayout.bottomBarInset)
    }

    // MARK: - Вспомогательные методы

    private func availableExpense(with id: UUID) -> Expense? {
        expenses.first { !$0.isDeleted && $0.modelContext != nil && $0.id == id }
    }
}

// MARK: - Превью

#Preview("For Trip") {
    let previewTrip = ExpenseMapPreviewData(forTrip: true)
    
    EventExpensesMapView(
        expenses: previewTrip.expenses,
        screenContextSubtitle: previewTrip.screenContextSubtitle
    )
        .modelContainer(previewTrip.container)
        .environment(previewTrip.settingsStore)
}

#Preview("For Location") {
    let previewLocation = ExpenseMapPreviewData()
    
    EventExpensesMapView(
        expenses: previewLocation.expenses,
        screenContextSubtitle: previewLocation.screenContextSubtitle
    )
        .modelContainer(previewLocation.container)
        .environment(previewLocation.settingsStore)
}

#Preview("Empty") {
    let previewWithoutExpenses = ExpenseMapPreviewData(includeExpenses: false)
    
    EventExpensesMapView(
        expenses: previewWithoutExpenses.expenses,
        screenContextSubtitle: previewWithoutExpenses.screenContextSubtitle
    )
        .modelContainer(previewWithoutExpenses.container)
        .environment(previewWithoutExpenses.settingsStore)
}
