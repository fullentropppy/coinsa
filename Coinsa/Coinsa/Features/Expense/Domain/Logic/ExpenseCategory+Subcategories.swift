//
//  ExpenseCategory+Subcategories.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseCategory {
    /// Дочерние подкатегории для категории.
    var subcategories: [ExpenseSubcategory] {
        ExpenseSubcategory.allCases.filter { $0.parentCategory == self }
    }
}
