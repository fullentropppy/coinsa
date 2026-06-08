//
//  ExpenseSubcategory+Category.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.06.2026.
//

extension ExpenseSubcategory {
    /// Родительская категория для подкатегории.
    var category: ExpenseCategory {
        for category in ExpenseCategory.allCases {
            if category.subcategories.contains(self) {
                return category
            }
        }
        return .miscellaneous
    }
}
