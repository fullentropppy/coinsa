//
//  Expense+ExpenseSubcategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension Expense {
    /// Подкатегория траты (из строкового значения).
    var subcategory: ExpenseSubcategory {
        ExpenseSubcategory.from(subcategoryRaw)
    }
}
