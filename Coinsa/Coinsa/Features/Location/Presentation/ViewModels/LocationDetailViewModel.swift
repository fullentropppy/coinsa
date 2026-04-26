//
//  LocationDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import Foundation

struct LocationDetailViewModel {
    // MARK: - Хранимые свойства

    let location: Location
    
    // MARK: - Вычисляемые свойства

    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var localCurrency: Currency {
        location.localCurrency
    }
    
    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }
    
    var eventHeaderData: EventSummaryData {
        let plannedAmountBase = location.calculatePlannedAmount(asBaseCurrency: true)
        let plannedAmountLocal = isHomeLocation ? nil : location.calculatePlannedAmount(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true)
        let actualAmountLocal = isHomeLocation ? nil : location.calculateActualAmount(asBaseCurrency: false)
        let localCurrency = isHomeLocation ? nil : localCurrency

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            plannedBaseAmount: plannedAmountBase,
            actualBaseAmount: actualAmountBase,
            baseCurrency: baseCurrency,
            plannedLocalAmount: plannedAmountLocal,
            actualLocalAmount: actualAmountLocal,
            localCurrency: localCurrency
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let isHomeLocation = localCurrency == baseCurrency
        let budgetByCategoryBase = location.calculatePlannedAmountByCategory(asBaseCurrency: true, withinDateRange: location.range)
        let expenseByCategoryBase = location.calculateActualAmountByCategory(asBaseCurrency: true, withinDateRange: location.range)

        let budgetByCategoryLocal = isHomeLocation
            ? nil
            : location.calculatePlannedAmountByCategory(asBaseCurrency: false, withinDateRange: location.range)
        let expenseByCategoryLocal = isHomeLocation
            ? nil
            : location.calculateActualAmountByCategory(asBaseCurrency: false, withinDateRange: location.range)

        return EventCategoryAnalyticsData(
            dateRange: location.range,
            baseCurrency: baseCurrency,
            localCurrency: isHomeLocation ? nil : localCurrency,
            budgetByCategory: slices(from: budgetByCategoryBase, localValues: budgetByCategoryLocal),
            expenseByCategory: slices(from: expenseByCategoryBase, localValues: expenseByCategoryLocal)
        )
    }
    
    var groupedExpenses: [(date: Date, expenses: [Expense])] {
        let today = Date().startOfDay
        let yesterday = today.adding(days: -1)
        
        var grouped: [Date: [Expense]] = [:]
        
        for expense in location.expenses {
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
    ) -> [CategoryAnalyticsSlice] {
        ExpenseCategory.allCases.map { category in
            CategoryAnalyticsSlice(
                category: category,
                baseAmount: baseValues[category] ?? 0,
                localAmount: localValues?[category]
            )
        }
    }
}
