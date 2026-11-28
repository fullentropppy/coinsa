//
//  TripGeneralExpensesContentView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

import SwiftUI
import SwiftData

/// Группы общих трат поездки с действиями, которыми управляет экран деталей.
struct TripGeneralExpensesContentView: View {
    // MARK: - Свойства

    let viewModel: TripGeneralExpensesViewModel
    let onCreate: () -> Void
    let onEdit: (Expense) -> Void
    let onDelete: (Expense) -> Void

    // MARK: - Тело View

    var body: some View {
        if viewModel.expenses.isEmpty {
            EmptyStateView(
                icon: Expense.primaryIcon,
                title: .tripGeneralExpensesEmptyStateTitle,
                description: .tripGeneralExpensesEmptyStateDescription,
                buttonLabel: .expenseAdd,
                action: onCreate
            )
            .listRowBackground(Color.clear)
        } else {
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
                                onDelete: { onDelete(expense) },
                                onEdit: { onEdit(expense) }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData(includeLocations: true, includeExpenses: true)

    NavigationStack {
        List {
            TripGeneralExpensesContentView(
                viewModel: TripGeneralExpensesViewModel(trip: preview.trip),
                onCreate: {},
                onEdit: { _ in },
                onDelete: { _ in }
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData()

    NavigationStack {
        List {
            TripGeneralExpensesContentView(
                viewModel: TripGeneralExpensesViewModel(trip: preview.trip),
                onCreate: {},
                onEdit: { _ in },
                onDelete: { _ in }
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
