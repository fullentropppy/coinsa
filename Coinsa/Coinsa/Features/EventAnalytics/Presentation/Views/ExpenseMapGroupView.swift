//
//  ExpenseMapGroupView.swift
//  Coinsa
//

import SwiftData
import SwiftUI

/// Список трат выбранной группы меток на карте с разделами по дням.
struct ExpenseMapGroupView: View {
    // MARK: - Окружение

    @Environment(\.dismiss) private var dismiss

    // MARK: - Свойства

    let expenses: [Expense]
    let expenseIDs: [UUID]
    let screenContextSubtitle: String

    private var viewModel: ExpenseMapGroupViewModel {
        ExpenseMapGroupViewModel(expenses: expenses, expenseIDs: expenseIDs)
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            expensesList
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
        }
    }

    // MARK: - Компоненты

    private var expensesList: some View {
        List {
            ForEach(viewModel.groupedExpenses, id: \.date) { group in
                Section(DateDisplayFormatter.formatRelative(group.date, showsTime: false)) {
                    ForEach(group.expenses) { expense in
                        NavigationLink {
                            ExpenseDetailView(expense)
                        } label: {
                            ExpenseRowView(expense)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Превью

#Preview {
    let preview = ExpenseMapPreviewData()
    
    ExpenseMapGroupView(
        expenses: preview.expenses,
        expenseIDs: preview.expenses.map(\.id),
        screenContextSubtitle: preview.screenContextSubtitle
    )
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
