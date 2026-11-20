//
//  EventCategoryAnalyticsSummary.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

/// Сводные данные по категории и ведущей подкатегории.
struct EventCategoryAnalyticsSummary {
    // MARK: - Хранимые свойства

    let category: ExpenseCategory
    let subcategory: ExpenseSubcategory
    let categoryExpenseCount: Int
    let subcategoryExpenseCount: Int
    let homeAmount: Double
    let locationAmount: Double?
    
    // MARK: - Публичные методы

    func hasSameTarget(as summary: EventCategoryAnalyticsSummary) -> Bool {
        category == summary.category && subcategory == summary.subcategory
    }
}
