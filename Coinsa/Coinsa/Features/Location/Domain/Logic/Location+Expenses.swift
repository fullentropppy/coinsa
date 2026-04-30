//
//  Location+Expenses.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Location {
    var hasExpenses: Bool {
        expenses?.isEmpty == false
    }
    
    var expensesCount: Int {
        expenses?.count ?? 0
    }
}
