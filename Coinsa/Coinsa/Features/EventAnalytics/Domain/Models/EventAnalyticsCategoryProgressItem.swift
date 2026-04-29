//
//  EventAnalyticsCategoryProgressItem.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

struct EventAnalyticsCategoryProgressItem: Identifiable {
    let category: ExpenseCategory
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?

    var id: String { category.id }
}
