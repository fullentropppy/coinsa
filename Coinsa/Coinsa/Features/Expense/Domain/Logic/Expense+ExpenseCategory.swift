//
//  Expense+ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Expense {
    var category: ExpenseCategory {
        ExpenseCategory.from(categoryRaw)
    }
}
