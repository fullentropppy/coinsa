//
//  ExpenseMapGroup.swift
//  Coinsa
//

import Foundation

/// Идентификаторы трат выбранной группы меток.
struct ExpenseMapGroup: Identifiable {
    let id = UUID()
    let expenseIDs: [UUID]
}
