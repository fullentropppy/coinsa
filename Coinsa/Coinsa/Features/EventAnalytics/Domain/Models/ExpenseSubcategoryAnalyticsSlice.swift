//
//  ExpenseSubcategoryAnalyticsSlice.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

/// Срез аналитических данных для одной подкатегории расходов.
struct ExpenseSubcategoryAnalyticsSlice: Identifiable {
    // MARK: - Хранимые свойства

    let category: ExpenseCategory
    let subcategory: ExpenseSubcategory
    let expenseCount: Int
    let homeAmount: Double
    let locationAmount: Double?
    
    // MARK: - Вычисляемые свойства

    var id: String { "\(category.id).\(subcategory.id)" }
}
