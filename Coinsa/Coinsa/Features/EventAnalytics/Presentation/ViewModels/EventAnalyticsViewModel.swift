//
//  EventAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.04.2026.
//

import SwiftUI

/// ViewModel для отображения аналитики события.ц
struct EventAnalyticsViewModel {
    // MARK: - Зависимости

    let data: EventCategoryAnalyticsData

    // MARK: - Хранимые свойства. Валюта

    var baseCurrency: Currency {
        data.baseCurrency
    }

    var locationCurrency: Currency? {
        data.locationCurrency
    }

    // MARK: - Хранимые свойства. Дни
    
    var startDate: Date {
        data.dateRangeProvider.startPlainDate.startOfDay
    }
    
    var endDate: Date {
        data.dateRangeProvider.endPlainDate.endOfDay
    }
    
    var totalDays: Int {
        data.dateRangeProvider.totalDays
    }
    
    var remainingDays: Int {
        data.dateRangeProvider.remainingDays
    }

    private var totalDayDivisor: Double {
        max(Double(totalDays), 1)
    }
    
    // MARK: - Хранимые свойства. Сумма в основной валюте

    var expensesTotalBaseAmount: Double {
        data.expensesAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var dailyBaseBudgetAmount: Double {
        data.baseBudget / totalDayDivisor
    }
    
    var dailyBaseExpensesAmount: Double {
        expensesTotalBaseAmount / totalDayDivisor
    }
    
    var baseAmountBalance: Double {
        data.baseBudget - expensesTotalBaseAmount
    }
    
    // MARK: - Хранимые свойства. Сумма в локальной валюте
    
    var expensesTotalLocationAmount: Double? {
        if locationCurrency != nil {
            data.expensesAmountByCategory.reduce(0) { $0 + ($1.locationAmount ?? 0) }
        } else {
            nil
        }
    }
    
    var dailyLocationBudgetAmount: Double? {
        if let localBudget = data.localBudget {
            localBudget / totalDayDivisor
        } else {
            nil
        }
    }
    
    var dailyLocationExpensesAmount: Double? {
        if let expensesTotalLocationAmount {
            expensesTotalLocationAmount / totalDayDivisor
        } else {
            nil
        }
    }
    
    var locationAmountBalance: Double? {
        if let localBudget = data.localBudget, let expensesTotalLocationAmount {
            localBudget - expensesTotalLocationAmount
        } else {
            nil
        }
    }
    
    // MARK: - Хранимые свойства. Общие данные
    
    var eventSummaryData: EventSummaryData {
        EventSummaryData(
            budgetBaseAmount: data.baseBudget,
            expensesBaseAmount: expensesTotalBaseAmount,
            baseCurrency: baseCurrency,
            budgetLocationAmount: data.localBudget,
            expensesLocationAmount: expensesTotalLocationAmount,
            locationCurrency: locationCurrency
        )
    }
    
    var totalExpensesCount: Int {
        data.expenses.count
    }
    
    var peakTime: EventDaySegmentAnalyticsData? {
        let grouped = Dictionary(grouping: data.expenses) { expense in
            DaySegment.from(hour: expense.civilDateTime.storedDate.hour(using: .utc))
        }
        
        return grouped.values
            .compactMap { (expenses: [Expense]) -> EventDaySegmentAnalyticsData? in
                guard let firstExpense = expenses.first else { return nil }
                
                let count = expenses.count
                
                return EventDaySegmentAnalyticsData(
                    timeOfDay: DaySegment.from(hour: firstExpense.civilDateTime.storedDate.hour(using: .utc)),
                    expenseCount: count
                )
            }
            .sorted {
                if $0.expenseCount != $1.expenseCount {
                    return $0.expenseCount > $1.expenseCount
                }
                return $0.expenseCount > $1.expenseCount
            }
            .first
    }
    
    var largestExpense: Expense? {
        data.expenses.max { $0.baseAmount < $1.baseAmount }
    }
    
    // MARK: - Публичные методы

    func displayedSlicesSortedByID(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.category.id > $1.category.id }
    }

    func displayedSlicesSortedByAmount(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.baseAmount > $1.baseAmount }
    }
    
    func displayedSubcategorySlicesSortedByAmount(for category: ExpenseCategory) -> [ExpenseSubcategoryAnalyticsSlice] {
        let categoryExpenses = data.expenses.filter { $0.category == category }
        let grouped = Dictionary(grouping: categoryExpenses) { $0.subcategory }
        
        return category.subcategories.compactMap { subcategory in
            let expenses = grouped[subcategory] ?? []
            let baseAmount = baseAmount(for: expenses)
            
            guard baseAmount > 0 else { return nil }
            
            return ExpenseSubcategoryAnalyticsSlice(
                category: category,
                subcategory: subcategory,
                expenseCount: expenses.count,
                baseAmount: baseAmount,
                locationAmount: locationAmount(for: expenses)
            )
        }
        .sorted {
            if $0.baseAmount != $1.baseAmount {
                return $0.baseAmount > $1.baseAmount
            }
            return $0.expenseCount > $1.expenseCount
        }
    }
    
    func hasAnalytics(for metric: EventAnalyticsMetric) -> Bool {
        switch metric {
        case .summary: true
        case .categories: !displayedSlicesSortedByID(for: metric).isEmpty
        }
    }

    func shareValue(for slice: ExpenseAnalyticsSlice, metric: EventAnalyticsMetric) -> Double {
        let totalBaseAmount = displayedSlicesSortedByID(for: metric).reduce(0) { $0 + $1.baseAmount }
        return totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
    }
    
    func shareValue(for slice: ExpenseSubcategoryAnalyticsSlice, category: ExpenseCategory) -> Double {
        let totalBaseAmount = displayedSubcategorySlicesSortedByAmount(for: category).reduce(0) { $0 + $1.baseAmount }
        return totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
    }

    // MARK: - Приватные методы

    private func slices(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        let slices: [ExpenseAnalyticsSlice]

        switch metric {
        case .summary:
            slices = data.expensesAmountByCategory /// Замениить
        case .categories:
            slices = data.expensesAmountByCategory
        }

        return slices.contains { $0.baseAmount > 0 } ? slices : []
    }
    
    private func categorySummary(
        for categoryExpenses: [Expense],
        sortSubcategories: ([Expense], [Expense]) -> Bool
    ) -> EventCategoryAnalyticsSummary? {
        guard let category = categoryExpenses.first?.category else { return nil }
        
        let subcategoryExpenses = Dictionary(grouping: categoryExpenses) { $0.subcategory }
            .values
            .sorted(by: sortSubcategories)
            .first
        
        guard let subcategory = subcategoryExpenses?.first?.subcategory else { return nil }
        
        return EventCategoryAnalyticsSummary(
            category: category,
            subcategory: subcategory,
            categoryExpenseCount: categoryExpenses.count,
            subcategoryExpenseCount: subcategoryExpenses?.count ?? 0,
            baseAmount: baseAmount(for: categoryExpenses),
            locationAmount: locationAmount(for: categoryExpenses)
        )
    }
    
    private func expenses(on date: PlainDate) -> [Expense] {
        data.expenses.filter { expense in
            PlainDate(expense.civilDateTime.storedDate, using: .utc) == date
        }
    }
    
    private func baseAmount(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.baseAmount }
    }
    
    private func locationAmount(for expenses: [Expense]) -> Double? {
        if locationCurrency != nil {
            expenses.reduce(0) { $0 + $1.amount(in: .location) }
        } else {
            nil
        }
    }
    
    private func locationAmountDifference(todayExpenses: [Expense], yesterdayExpenses: [Expense]) -> Double? {
        if let todayLocationAmount = locationAmount(for: todayExpenses),
           let yesterdayLocationAmount = locationAmount(for: yesterdayExpenses) {
            todayLocationAmount - yesterdayLocationAmount
        } else {
            nil
        }
    }
}
