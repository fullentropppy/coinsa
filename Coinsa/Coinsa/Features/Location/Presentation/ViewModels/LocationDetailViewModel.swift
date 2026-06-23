//
//  LocationDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import Foundation

/// ViewModel для детального экрана локации.
struct LocationDetailViewModel {
    // MARK: - Хранимые свойства

    let location: Location
    
    // MARK: - Вычисляемые свойства. Общее

    var navigationTitle: String {
        location.name
    }
    
    var navigationSubtitle: String {
        location.trip?.screenContextSubtitle ?? ""
    }
    
    // MARK: - Вычисляемые свойства. Валюта и сумма
    
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var locationCurrency: Currency {
        location.locationCurrency
    }
    
    var isHomeLocation: Bool {
        baseCurrency == locationCurrency
    }
    
    // MARK: - Вычисляемые свойства. Общие данные
    
    var eventHeaderData: EventSummaryData {
        let plannedBaseAmount = location.calculatePlannedAmount(in: CurrencyContext.base)
        let plannedLocalAmount = isHomeLocation ? nil : location.calculatePlannedAmount(in: CurrencyContext.location)
        let actualAmountBase = location.calculateActualAmount(in: CurrencyContext.base)
        let actualAmountLocal = isHomeLocation ? nil : location.calculateActualAmount(in: CurrencyContext.location)
        let locationCurrency = isHomeLocation ? nil : locationCurrency

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            plannedBaseAmount: plannedBaseAmount,
            actualBaseAmount: actualAmountBase,
            baseCurrency: baseCurrency,
            plannedLocalAmount: plannedLocalAmount,
            actualLocalAmount: actualAmountLocal,
            locationCurrency: locationCurrency
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let isHomeLocation = locationCurrency == baseCurrency
        
        let actualAmountByCategoryBase = location.calculateActualAmountByCategory(
            in: CurrencyContext.base,
            withinDateRange: location.range
        )

        let actualLocalAmountByCategory = isHomeLocation
            ? nil
            : location.calculateActualAmountByCategory(in: CurrencyContext.location, withinDateRange: location.range)
        let localBudget = isHomeLocation ? nil : location.calculatePlannedAmount(in: CurrencyContext.location)

        return EventCategoryAnalyticsData(
            dateRange: location.range,
            baseCurrency: baseCurrency,
            locationCurrency: isHomeLocation ? nil : locationCurrency,
            baseBudget: location.budget,
            localBudget: localBudget,
            actualAmountByCategory: slices(from: actualAmountByCategoryBase, localValues: actualLocalAmountByCategory)
        )
    }
    
    var groupedExpenses: [(date: Date, expenses: [Expense])] {
        guard let expenses = location.expenses, !expenses.isEmpty else { return [] }
        
        let today = Date().startOfDay
        let yesterday = today.adding(days: -1)
        
        var grouped: [Date: [Expense]] = [:]
        
        for expense in expenses {
            grouped[expense.date.startOfDay, default: []].append(expense)
        }
        
        for day in grouped.keys {
            grouped[day] = grouped[day]?.sorted { $0.date > $1.date }
        }
        
        var result: [(date: Date, expenses: [Expense])] = []
        
        let futureDates = grouped.keys
            .filter { $0 > today }
            .sorted(by: >)
        
        for date in futureDates {
            if let expensesForDate = grouped[date] {
                result.append((date: date, expenses: expensesForDate))
            }
        }
        
        if let todayExpenses = grouped[today] {
            result.append((date: today, expenses: todayExpenses))
        }
        
        if let yesterdayExpenses = grouped[yesterday] {
            result.append((date: yesterday, expenses: yesterdayExpenses))
        }
        
        let pastDates = grouped.keys
            .filter { $0 < yesterday }
            .sorted(by: >)
        
        for date in pastDates {
            if let expensesForDate = grouped[date] {
                result.append((date: date, expenses: expensesForDate))
            }
        }
        
        return result
    }

    // MARK: - Приватные методы

    private func slices(
    from baseValues: [ExpenseCategory: Double],
        localValues: [ExpenseCategory: Double]?
    ) -> [ExpenseAnalyticsSlice] {
        ExpenseCategory.allCases.map { category in
            ExpenseAnalyticsSlice(
                category: category,
                baseAmount: baseValues[category] ?? 0,
                localAmount: localValues?[category]
            )
        }
    }
}
