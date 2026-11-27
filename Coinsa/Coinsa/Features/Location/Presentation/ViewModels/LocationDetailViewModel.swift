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
    
    var homeCurrency: Currency {
        location.homeCurrency
    }
    
    var locationCurrency: Currency {
        location.locationCurrency
    }
    
    var isHomeLocation: Bool {
        homeCurrency == locationCurrency
    }
    
    // MARK: - Вычисляемые свойства. Общие данные
    
    var eventHeaderData: EventSummaryData {
        let budgetHomeAmount = location.calculateBudgetAmount(in: CurrencyContext.home)
        let budgetLocationAmount = isHomeLocation ? nil : location.calculateBudgetAmount(in: CurrencyContext.location)
        let expensesHomeAmount = location.calculateExpensesAmount(in: CurrencyContext.home)
        let expensesLocationAmount = isHomeLocation ? nil : location.calculateExpensesAmount(in: CurrencyContext.location)
        let locationCurrency = isHomeLocation ? nil : locationCurrency
        let homeAmountBalance = budgetHomeAmount - expensesHomeAmount

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            budgetHomeAmount: budgetHomeAmount,
            expensesHomeAmount: expensesHomeAmount,
            homeCurrency: homeCurrency,
            budgetLocationAmount: budgetLocationAmount,
            expensesLocationAmount: expensesLocationAmount,
            locationCurrency: locationCurrency,
            homeAmountBalance: homeAmountBalance,
            locationAmountBalance: isHomeLocation ? nil : location.currencyConversion.locationAmount(forHomeAmount: homeAmountBalance)
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let isHomeLocation = locationCurrency == homeCurrency
        
        let expensesAmountByCategoryBase = location.calculateExpensesAmountByCategory(
            in: CurrencyContext.home
        )

        let expensesLocationAmountByCategory = isHomeLocation ? nil : location.calculateExpensesAmountByCategory(
            in: CurrencyContext.location
        )

        return EventCategoryAnalyticsData(
            title: location.name,
            dateRangeProvider: location,
            homeCurrency: homeCurrency,
            locationCurrency: isHomeLocation ? nil : locationCurrency,
            baseBudget: location.budget,
            locationConversion: isHomeLocation ? nil : location.currencyConversion,
            expensesAmountByCategory: slices(from: expensesAmountByCategoryBase, localValues: expensesLocationAmountByCategory),
            expenses: location.expenses ?? [],
            locations: nil
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
                homeAmount: baseValues[category] ?? 0,
                locationAmount: localValues?[category]
            )
        }
    }
}
