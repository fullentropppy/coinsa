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
        let budgetBaseAmount = location.calculateBudgetAmount(in: CurrencyContext.base)
        let budgetLocationAmount = isHomeLocation ? nil : location.calculateBudgetAmount(in: CurrencyContext.location)
        let expensesAmountBase = location.calculateExpensesAmount(in: CurrencyContext.base)
        let expensesAmountLocal = isHomeLocation ? nil : location.calculateExpensesAmount(in: CurrencyContext.location)
        let locationCurrency = isHomeLocation ? nil : locationCurrency

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            budgetBaseAmount: budgetBaseAmount,
            expensesBaseAmount: expensesAmountBase,
            baseCurrency: baseCurrency,
            budgetLocationAmount: budgetLocationAmount,
            expensesLocationAmount: expensesAmountLocal,
            locationCurrency: locationCurrency
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let isHomeLocation = locationCurrency == baseCurrency
        
        let expensesAmountByCategoryBase = location.calculateExpensesAmountByCategory(
            in: CurrencyContext.base,
            withinDateRange: location.range
        )

        let expensesLocationAmountByCategory = isHomeLocation ? nil : location.calculateExpensesAmountByCategory(
            in: CurrencyContext.location,
            withinDateRange: location.range
        )
        let locationBudget = isHomeLocation ? nil : location.calculateBudgetAmount(in: CurrencyContext.location)

        return EventCategoryAnalyticsData(
            dateRangeProvider: location,
            baseCurrency: baseCurrency,
            locationCurrency: isHomeLocation ? nil : locationCurrency,
            baseBudget: location.budget,
            locationBudget: locationBudget,
            expensesAmountByCategory: slices(from: expensesAmountByCategoryBase, localValues: expensesLocationAmountByCategory),
            expenses: location.expenses ?? []
        )
    }
    
    var groupedExpenses: [(date: CivilDateTime, expenses: [Expense])] {
        guard let expenses = location.expenses, !expenses.isEmpty else { return [] }
        
        let today = CivilDateTime.now.startOfDay
        let yesterday = today.adding(days: -1, using: .utc)
        
        var grouped: [CivilDateTime: [Expense]] = [:]
        
        for expense in expenses {
            grouped[CivilDateTime(expense.civilDateTime.startOfDay, using: .utc), default: []].append(expense)
        }
        
        for day in grouped.keys {
            grouped[day] = grouped[day]?.sorted { $0.civilDateTime > $1.civilDateTime }
        }
        
        var result: [(date: CivilDateTime, expenses: [Expense])] = []
        
        let futureDates = grouped.keys
            .filter { $0.storedDate > today }
            .sorted(by: >)
        
        for date in futureDates {
            if let expensesForDate = grouped[date] {
                result.append((date: date, expenses: expensesForDate))
            }
        }
        
        let todayDateTime = CivilDateTime(today, using: .utc)
        if let todayExpenses = grouped[todayDateTime] {
            result.append((date: todayDateTime, expenses: todayExpenses))
        }
        
        let yesterdayDateTime = CivilDateTime(yesterday, using: .utc)
        if let yesterdayExpenses = grouped[yesterdayDateTime] {
            result.append((date: yesterdayDateTime, expenses: yesterdayExpenses))
        }
        
        let pastDates = grouped.keys
            .filter { $0.storedDate < yesterday }
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
                locationAmount: localValues?[category]
            )
        }
    }
}
