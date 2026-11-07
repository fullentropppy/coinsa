//
//  ExpenseAnalyticsSlice.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

/// Срез аналитических данных для одной категории расходов.
struct ExpenseAnalyticsSlice: Identifiable {
    let category: ExpenseCategory
    let homeAmount: Double
    let locationAmount: Double?
    
    var id: String { category.id }
}
