//
//  Budget+ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Budget {
    /// Категория расхода для бюджета (из строкового значения).
    var category: ExpenseCategory {
        ExpenseCategory.from(categoryRaw)
    }
}
