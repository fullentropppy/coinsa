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
    let baseCurrency: Currency
    let localCurrency: Currency
    
    // MARK: - Вычисляемые свойства

    var eventHeaderData: EventSummaryData {
        let isHomeLocation = localCurrency == baseCurrency
        
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
        
        if let todayExpenses = grouped[today] {
            result.append((date: today, expenses: todayExpenses))
        }
        
        if let yesterdayExpenses = grouped[yesterday] {
            result.append((date: yesterday, expenses: yesterdayExpenses))
        }
        
        let otherDates = grouped.keys
            .filter { $0 != today && $0 != yesterday }
            .sorted(by: >)
        
        for date in otherDates {
            if let expensesForDate = grouped[date] {
                result.append((date: date, expenses: expensesForDate))
            }
        }
        
        return result
    }
    
    // MARK: - Инициализация

    init(location: Location, baseCurrency: Currency) {
        self.location = location
        self.baseCurrency = baseCurrency
        self.localCurrency = Currency.from(location.localCurrencyCode)
    }
}
