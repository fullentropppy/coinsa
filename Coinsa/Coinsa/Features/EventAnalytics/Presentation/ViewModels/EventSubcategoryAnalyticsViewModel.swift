//
//  EventSubcategoryAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Параметры отображения и траты выбранной категории для вложенной аналитики.
struct EventSubcategoryAnalyticsViewModel: Equatable {
    let category: ExpenseCategory
    let amountMode: CategoryAmountMode
    let totalDays: Int
    let homeCurrency: Currency
    let locationCurrency: Currency?
    let expenses: [Expense]
    let expensesBySubcategory: [ExpenseSubcategory: [Expense]]
    let showsLocationNames: Bool

    var amountDivisor: Double {
        switch amountMode {
        case .total: 1
        case .daily: max(Double(totalDays), 1)
        }
    }

    var displayedSlices: [ExpenseSubcategoryAnalyticsSlice] {
        let grouped = Dictionary(grouping: expenses) { $0.subcategory }

        return category.subcategories.compactMap { subcategory in
            let expenses = grouped[subcategory] ?? []
            let homeAmount = expenses.reduce(0) { $0 + $1.homeAmount }

            guard homeAmount > 0 else { return nil }

            return ExpenseSubcategoryAnalyticsSlice(
                category: category,
                subcategory: subcategory,
                expenseCount: expenses.count,
                homeAmount: homeAmount,
                locationAmount: locationCurrency == nil ? nil : expenses.reduce(0) { $0 + $1.amount(in: .location) }
            )
        }
        .sorted {
            if $0.homeAmount != $1.homeAmount {
                return $0.homeAmount > $1.homeAmount
            }
            return $0.expenseCount > $1.expenseCount
        }
    }

    func shareValue(for slice: ExpenseSubcategoryAnalyticsSlice, among slices: [ExpenseSubcategoryAnalyticsSlice]) -> Double {
        let totalHomeAmount = slices.reduce(0) { $0 + $1.homeAmount }
        return totalHomeAmount > 0 ? slice.homeAmount / totalHomeAmount : 0
    }
}
