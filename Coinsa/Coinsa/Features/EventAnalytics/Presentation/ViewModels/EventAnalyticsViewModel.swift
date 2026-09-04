//
//  EventAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.04.2026.
//

import SwiftUI

/// ViewModel для отображения аналитики события.
struct EventAnalyticsViewModel {
    // MARK: - Статические свойства
    
    private static let secondsPerDay: TimeInterval = 24 * 60 * 60
    
    // MARK: - Зависимости

    let data: EventCategoryAnalyticsData

    // MARK: - Вычисляемые свойства. Дни
    
    var totalDays: Int {
        data.dateRangeProvider.totalDays
    }

    private var totalDayDivisor: Double {
        max(Double(totalDays), 1)
    }
    
    // MARK: - Вычисляемые свойства. Валюта

    var baseCurrency: Currency {
        data.baseCurrency
    }

    var locationCurrency: Currency? {
        data.locationCurrency
    }
    
    // MARK: - Вычисляемые свойства. Сумма в основной валюте

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
    
    // MARK: - Вычисляемые свойства. Сумма в валюте локации
    
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
    
    // MARK: - Вычисляемые свойства. Сводная аналитика
    
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

    // MARK: - Вычисляемые свойства. Дневная аналитика

    private var summaryChartPlainDates: [PlainDate] {
        let expensePlainDates = data.expenses.map { PlainDate($0.civilDateTime.storedDate, using: .utc) }
        
        guard let firstExpenseDate = expensePlainDates.min(), let lastExpenseDate = expensePlainDates.max() else {
            let daysCount = max(totalDays, 0)
            return (0..<daysCount).map { data.dateRangeProvider.startPlainDate.adding(days: $0) }
        }

        let startDate = firstExpenseDate.adding(days: -2)
        let endDate = lastExpenseDate.adding(days: 2)
        let daysCount = max(endDate.days(from: startDate) + 2, 0)

        return (0..<daysCount).map { startDate.adding(days: $0) }
    }
    
    var summaryExpenseChartPoints: [EventDailyExpenseAnalyticsData] {
        let expensesByDate = Dictionary(grouping: data.expenses) { expense in
            PlainDate(expense.civilDateTime.storedDate, using: .utc)
        }

        return summaryChartPlainDates.map { date in
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

    var middleDailyBaseExpenseAmount: Double {
        maxDailyBaseExpenseAmount / 2
    }

    var middleDailyLocationExpenseAmount: Double? {
        if let maxDailyLocationExpenseAmount {
            maxDailyLocationExpenseAmount / 2
        } else {
            nil
        }
    }

    var summaryChartUpperBaseAmount: Double {
        max(maxDailyBaseExpenseAmount, 1)
    }

    var summaryChartXDomain: ClosedRange<Date> {
        let startDate = summaryChartPlainDates.first?.startOfDay ?? data.dateRangeProvider.startPlainDate.startOfDay
        let endDate = summaryChartPlainDates.last?.startOfDay ?? data.dateRangeProvider.endPlainDate.startOfDay

        if startDate < endDate {
            return startDate...endDate
        } else {
            return startDate...startDate.adding(days: 1, using: .utc)
        }
    }

    var summaryChartXVisibleDomainLength: TimeInterval {
        let totalVisibleDays = max(summaryChartPlainDates.count - 2, 1)
        let preferredVisibleDays = min(totalVisibleDays, 7)
        return TimeInterval(preferredVisibleDays) * Self.secondsPerDay
    }
    
    // MARK: - Публичные методы
    
    func summaryChartScrollPosition(for date: PlainDate) -> Date {
        let domain = summaryChartXDomain
        let visibleLength = summaryChartXVisibleDomainLength
        let centeredPosition = date.startOfDay.addingTimeInterval(-visibleLength / 2)
        let latestPosition = max(domain.lowerBound, domain.upperBound.addingTimeInterval(-visibleLength))
        
        return min(max(centeredPosition, domain.lowerBound), latestPosition)
    }

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
        case .days: totalDays > 1 && expensesTotalBaseAmount > 0
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
