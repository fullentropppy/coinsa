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

    // MARK: - Вычисляемые свойства. Дни
    
    var totalDays: Int {
        data.dateRangeProvider.totalDays
    }

    private var totalDayDivisor: Double {
        max(Double(totalDays), 1)
    }
    
    // MARK: - Вычисляемые свойства. Валюта

    var homeCurrency: Currency {
        data.homeCurrency
    }

    var locationCurrency: Currency? {
        data.locationCurrency
    }
    
    // MARK: - Вычисляемые свойства. Сумма в домашней валюте

    var expensesTotalHomeAmount: Double {
        data.expensesAmountByCategory.reduce(0) { $0 + $1.homeAmount }
    }

    var locationsExpensesTotalHomeAmount: Double {
        homeAmount(for: data.expenses.filter { $0.location != nil && $0.owningTrip != nil })
    }

    var locationsDailyHomeExpensesAmount: Double {
        locationsExpensesTotalHomeAmount / totalDayDivisor
    }

    var dailyHomeBudgetAmount: Double {
        data.baseBudget / totalDayDivisor
    }
    
    var dailyHomeExpensesAmount: Double {
        expensesTotalHomeAmount / totalDayDivisor
    }
    
    var homeAmountBalance: Double {
        data.baseBudget - expensesTotalHomeAmount
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
            budgetHomeAmount: data.baseBudget,
            expensesHomeAmount: expensesTotalHomeAmount,
            homeCurrency: homeCurrency,
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
        
        guard let peakCount = grouped.values.map(\.count).max(),
              let peakSegment = DaySegment.allCases.first(where: { grouped[$0]?.count == peakCount }) else {
            return nil
        }

        return EventDaySegmentAnalyticsData(timeOfDay: peakSegment, expenseCount: peakCount)
    }
    
    var largestExpense: Expense? {
        data.expenses.max { $0.homeAmount < $1.homeAmount }
    }

    // MARK: - Вычисляемые свойства. Дневная аналитика

    private var summaryChartPlainDates: [PlainDate] {
        let expensePlainDates = data.expenses.map { PlainDate($0.civilDateTime.storedDate, using: .utc) }
        
        guard let firstExpenseDate = expensePlainDates.min(), let lastExpenseDate = expensePlainDates.max() else {
            let daysCount = max(totalDays, 0)
            return (0..<daysCount).map { data.dateRangeProvider.startPlainDate.adding(days: $0) }
        }

        let startDate = firstExpenseDate.adding(days: -2)
        let endDate = lastExpenseDate.adding(days: 1)
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
                expenseCount: expenses.count,
                homeAmount: homeAmount(for: expenses),
                locationAmount: locationAmount(for: expenses)
            )
        }
    }

    var summaryChartPeakPoint: EventDailyExpenseAnalyticsData? {
        summaryExpenseChartPoints.max { $0.homeAmount < $1.homeAmount }
    }

    var maxDailyBaseExpenseAmount: Double {
        summaryChartPeakPoint?.homeAmount ?? 0
    }

    var maxDailyLocationExpenseAmount: Double? {
        summaryChartPeakPoint?.locationAmount
    }

    var halfDailyBaseExpenseAmount: Double {
        maxDailyBaseExpenseAmount / 2
    }

    var halfDailyLocationExpenseAmount: Double? {
        if let maxDailyLocationExpenseAmount {
            maxDailyLocationExpenseAmount / 2
        } else {
            nil
        }
    }

    var summaryChartUpperHomeAmount: Double {
        max(maxDailyBaseExpenseAmount, 1)
    }

    var summaryChartTimeline: EventExpenseChartTimeline {
        EventExpenseChartTimeline(days: summaryExpenseChartPoints)
    }

    // MARK: - Вычисляемые свойства. Аналитика локаций

    var locationSlices: [EventLocationAnalyticsSlice] {
        let expensesByLocation = Dictionary(grouping: data.expenses.filter {
            $0.location != nil && $0.owningTrip != nil
        }) { $0.location?.id }
        return (data.locations ?? []).sorted {
            if $0.startPlainDate != $1.startPlainDate {
                return $0.startPlainDate < $1.startPlainDate
            }
            return $0.id.uuidString < $1.id.uuidString
        }.map { location in
            let expenses = expensesByLocation[location.id] ?? []
            return EventLocationAnalyticsSlice(
                location: location,
                homeAmount: homeAmount(for: expenses),
                expenseCount: expenses.count
            )
        }
    }

    // MARK: - Публичные методы

    func displayedLocationSlices(from slices: [EventLocationAnalyticsSlice], asDailyAverage: Bool) -> [EventLocationAnalyticsSlice] {
        slices.sorted {
            let firstAmount = $0.amount(asDailyAverage: asDailyAverage)
            let secondAmount = $1.amount(asDailyAverage: asDailyAverage)
            if firstAmount != secondAmount {
                return firstAmount > secondAmount
            }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    func shareValue(for slice: EventLocationAnalyticsSlice, among slices: [EventLocationAnalyticsSlice], asDailyAverage: Bool) -> Double {
        let totalAmount = slices.reduce(0) { $0 + $1.amount(asDailyAverage: asDailyAverage) }
        return totalAmount > 0 ? slice.amount(asDailyAverage: asDailyAverage) / totalAmount : 0
    }

    func displayedSlicesSortedByID(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.category.id > $1.category.id }
    }

    func displayedSlicesSortedByAmount(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.homeAmount > $1.homeAmount }
    }
    
    func subcategoryViewModels(amountMode: CategoryAmountMode) -> [ExpenseCategory: EventSubcategoryAnalyticsViewModel] {
        let expensesByCategory = Dictionary(grouping: data.expenses) { $0.category }
        let expensesBySubcategory = Dictionary(grouping: data.expenses) { $0.subcategory }
        let totalDays = totalDays

        return Dictionary(uniqueKeysWithValues: ExpenseCategory.allCases.map { category in
            let viewModel = EventSubcategoryAnalyticsViewModel(
                category: category,
                amountMode: amountMode,
                totalDays: totalDays,
                homeCurrency: homeCurrency,
                locationCurrency: locationCurrency,
                expenses: expensesByCategory[category] ?? [],
                expensesBySubcategory: expensesBySubcategory.filter { category.subcategories.contains($0.key) },
                showsLocationNames: data.locations != nil
            )
            return (category, viewModel)
        })
    }
    
    func hasAnalytics(for metric: EventAnalyticsMetric) -> Bool {
        switch metric {
        case .summary: true
        case .days: totalDays > 1 && expensesTotalHomeAmount > 0
        case .categories: !displayedSlicesSortedByID(for: metric).isEmpty
        case .locations: data.locations?.isEmpty == false
        }
    }

    func expenseCount(for category: ExpenseCategory) -> Int {
        data.expenses.lazy.filter { $0.category == category }.count
    }

    func shareValue(for slice: ExpenseAnalyticsSlice, metric: EventAnalyticsMetric) -> Double {
        let totalHomeAmount = displayedSlicesSortedByID(for: metric).reduce(0) { $0 + $1.homeAmount }
        return totalHomeAmount > 0 ? slice.homeAmount / totalHomeAmount : 0
    }
    
    // MARK: - Приватные методы

    private func slices(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        let slices: [ExpenseAnalyticsSlice]

        switch metric {
        case .summary, .days, .locations:
            slices = []
        case .categories:
            slices = data.expensesAmountByCategory
        }

        return slices.contains { $0.homeAmount > 0 } ? slices : []
    }
    
    private func homeAmount(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.homeAmount }
    }
    
    private func locationAmount(for expenses: [Expense]) -> Double? {
        if locationCurrency != nil {
            expenses.reduce(0) { $0 + $1.amount(in: .location) }
        } else {
            nil
        }
    }
}
