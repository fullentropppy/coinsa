//
//  ExpenseMapGroup.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Идентификаторы трат выбранной группы меток.
struct ExpenseMapGroup: Identifiable {
    let id = UUID()
    let expenseIDs: [UUID]
}
