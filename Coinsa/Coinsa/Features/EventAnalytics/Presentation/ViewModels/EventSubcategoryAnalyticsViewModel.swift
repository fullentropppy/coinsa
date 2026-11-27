//
//  EventSubcategoryAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Параметры отображения и траты выбранной категории для вложенной аналитики.
struct EventSubcategoryAnalyticsViewModel: Equatable {
    // MARK: - Хранимые свойства

    let category: ExpenseCategory
    let amountMode: CategoryAmountMode
    let totalDays: Int
    let homeCurrency: Currency
    let locationCurrency: Currency?
    let locationConversion: LocationCurrencyConversion?
    let expenses: [Expense]
    let expensesBySubcategory: [ExpenseSubcategory: [Expense]]
    let showsLocationNames: Bool

    // MARK: - Вычисляемые свойства

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
                locationAmount: locationCurrency == nil ? nil : locationConversion?.locationAmount(forHomeAmount: homeAmount)
            )
        }
        .sorted {
            if $0.homeAmount != $1.homeAmount {
                return $0.homeAmount > $1.homeAmount
            }
            return $0.expenseCount > $1.expenseCount
        }
    }

    // MARK: - Публичные методы

    func shareValue(for slice: ExpenseSubcategoryAnalyticsSlice, among slices: [ExpenseSubcategoryAnalyticsSlice]) -> Double {
        let totalHomeAmount = slices.reduce(0) { $0 + $1.homeAmount }
        return totalHomeAmount > 0 ? slice.homeAmount / totalHomeAmount : 0
    }
}
