//
//  ExpenseMapGroupViewModel.swift
//  Coinsa
//

import Foundation
import SwiftData

/// Отбор трат группы карты и их представление по гражданским календарным дням.
struct ExpenseMapGroupViewModel {
    let expenses: [Expense]
    let expenseIDs: [UUID]

    var groupedExpenses: [(date: CivilDateTime, expenses: [Expense])] {
        let ids = Set(expenseIDs)
        let matchedExpenses = expenses.filter {
            !$0.isDeleted && $0.modelContext != nil && $0.coordinate != nil && ids.contains($0.id)
        }
        let grouped = Dictionary(grouping: matchedExpenses) { expense in
            CivilDateTime(expense.civilDateTime.startOfDay, using: .utc)
        }

        return grouped.keys.sorted(by: >).map { date in
            (
                date: date,
                expenses: (grouped[date] ?? []).sorted { $0.civilDateTime > $1.civilDateTime }
            )
        }
    }
}
