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
    let totalDays: Int
    let homeCurrency: Currency
    let locationCurrency: Currency?
    let locationConversion: LocationCurrencyConversion?
    let expenses: [Expense]
    let expensesBySubcategory: [ExpenseSubcategory: [Expense]]
    let showsLocationNames: Bool

    // MARK: - Вычисляемые свойства

    var expensesSummary: EventAnalyticsExpensesSummary {
        makeExpensesSummary(for: expenses)
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

    func expensesSummary(for subcategory: ExpenseSubcategory) -> EventAnalyticsExpensesSummary {
        makeExpensesSummary(for: expensesBySubcategory[subcategory] ?? [])
    }

    func shareValue(for slice: ExpenseSubcategoryAnalyticsSlice, among slices: [ExpenseSubcategoryAnalyticsSlice]) -> Double {
        let totalHomeAmount = slices.reduce(0) { $0 + $1.homeAmount }
        return totalHomeAmount > 0 ? slice.homeAmount / totalHomeAmount : 0
    }

    // MARK: - Вспомогательные методы

    private func makeExpensesSummary(for expenses: [Expense]) -> EventAnalyticsExpensesSummary {
        let homeAmount = expenses.reduce(0) { $0 + $1.homeAmount }
        let dailyHomeAmount = homeAmount / max(Double(totalDays), 1)

        return EventAnalyticsExpensesSummary(
            homeAmount: homeAmount,
            homeCurrency: homeCurrency,
            locationAmount: locationCurrency == nil ? nil : locationConversion?.locationAmount(forHomeAmount: homeAmount),
            locationCurrency: locationCurrency,
            dailyHomeAmount: dailyHomeAmount,
            dailyLocationAmount: locationCurrency == nil ? nil : locationConversion?.locationAmount(forHomeAmount: dailyHomeAmount),
            totalDays: totalDays
        )
    }
}
