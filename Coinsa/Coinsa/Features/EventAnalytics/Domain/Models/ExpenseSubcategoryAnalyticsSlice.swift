//
//  ExpenseSubcategoryAnalyticsSlice.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

/// Срез аналитических данных для одной подкатегории расходов.
struct ExpenseSubcategoryAnalyticsSlice: Identifiable {
    let category: ExpenseCategory
    let subcategory: ExpenseSubcategory
    let expenseCount: Int
    let baseAmount: Double
    let locationAmount: Double?
    
    var id: String { "\(category.id).\(subcategory.id)" }
}
