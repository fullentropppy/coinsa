//
//  Location+Expenses.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Location {
    /// Признак наличия бюджета в локации.
    var hasBudget: Bool {
        budget > 0
    }
    
    /// Признак наличия трат в локации.
    var hasExpenses: Bool {
        expenses?.isEmpty == false
    }
    
    /// Количество трат в локации.
    var expensesCount: Int {
        expenses?.count ?? 0
    }
}
