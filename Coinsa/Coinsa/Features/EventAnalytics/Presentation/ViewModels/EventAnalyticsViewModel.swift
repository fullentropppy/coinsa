//
//  EventAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.04.2026.
//

import SwiftUI

/// ViewModel для отображения аналитики события.
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
    
    var totalDays: Int {
        data.dateRangeProvider.totalDays
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
        if let locationBudget = data.locationBudget {
            locationBudget / totalDayDivisor
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
        if let locationBudget = data.locationBudget, let expensesTotalLocationAmount {
            locationBudget - expensesTotalLocationAmount
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
            budgetLocationAmount: data.locationBudget,
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
                
                return EventDaySegmentAnalyticsData(
                    timeOfDay: DaySegment.from(hour: firstExpense.civilDateTime.storedDate.hour(using: .utc)),
                    expenseCount: expenses.count
                )
            }
            .sorted { $0.expenseCount > $1.expenseCount }
            .first
    }
    
    var largestExpense: Expense? {
        data.expenses.max { $0.baseAmount < $1.baseAmount }
    }

    // MARK: - Хранимые свойства. Дневная аналитика

    var summaryExpenseChartPoints: [EventDailyExpenseAnalyticsData] {
        let expensesByDate = Dictionary(grouping: data.expenses) { expense in
            PlainDate(expense.civilDateTime.storedDate, using: .utc)
        }

        return eventPlainDates.map { date in
            let expenses = expensesByDate[date] ?? []

            return EventDailyExpenseAnalyticsData(
                date: date,
                baseAmount: baseAmount(for: expenses),
                locationAmount: locationAmount(for: expenses)
            )
        }
    }

    var summaryChartPeakPoint: EventDailyExpenseAnalyticsData? {
        summaryExpenseChartPoints.max { $0.baseAmount < $1.baseAmount }
    }

    var maxDailyBaseExpenseAmount: Double {
        summaryChartPeakPoint?.baseAmount ?? 0
    }

    var maxDailyLocationExpenseAmount: Double? {
        summaryChartPeakPoint?.locationAmount
    }

    var averageDailyBaseExpenseAmount: Double {
        dailyBaseExpensesAmount
    }

    var averageDailyLocationExpenseAmount: Double? {
        dailyLocationExpensesAmount
    }

    var summaryChartUpperBaseAmount: Double {
        max(maxDailyBaseExpenseAmount, averageDailyBaseExpenseAmount, 1)
    }

    var summaryChartXDomain: ClosedRange<Date> {
        let startDate = data.dateRangeProvider.startPlainDate.startOfDay
        let endDate = data.dateRangeProvider.endPlainDate.startOfDay

        if startDate < endDate {
            return startDate...endDate
        } else {
            return startDate...startDate.adding(days: 1, using: .utc)
        }
    }

    var summaryChartXAxisValues: [Date] {
        let dates = eventPlainDates
        guard let lastIndex = dates.indices.last else { return [] }

        let maxVisibleLabels = 10
        guard dates.count > maxVisibleLabels else {
            return dates.map { $0.startOfDay }
        }

        let step = max(Int(ceil(Double(lastIndex) / Double(maxVisibleLabels - 1))), 1)
        var indices = Array(stride(from: dates.startIndex, through: lastIndex, by: step))

        if indices.last != lastIndex {
            indices.append(lastIndex)
        }

        return indices.map { dates[$0].startOfDay }
    }

    var summaryChartXAxisInteriorValues: [Date] {
        guard let startDate = summaryChartStartDate,
              let endDate = summaryChartEndDate,
              startDate != endDate else { return [] }

        return summaryChartXAxisValues.filter { $0 != startDate && $0 != endDate }
    }

    var summaryChartXAxisEdgeValues: [Date] {
        guard let startDate = summaryChartStartDate else { return [] }
        guard let endDate = summaryChartEndDate, startDate != endDate else { return [startDate] }

        return [startDate, endDate]
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
        case .days: totalDays > 1
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

    // MARK: - Приватные свойства

    private var eventPlainDates: [PlainDate] {
        let daysCount = max(totalDays, 0)
        return (0..<daysCount).map { data.dateRangeProvider.startPlainDate.adding(days: $0) }
    }

    private var summaryChartStartDate: Date? {
        eventPlainDates.first?.startOfDay
    }

    private var summaryChartEndDate: Date? {
        eventPlainDates.last?.startOfDay
    }

    // MARK: - Приватные методы

    private func slices(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        let slices: [ExpenseAnalyticsSlice]

        switch metric {
        case .summary, .days:
            slices = []
        case .categories:
            slices = data.expensesAmountByCategory
        }

        return slices.contains { $0.baseAmount > 0 } ? slices : []
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
}
