//
//  LocationDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import Foundation
import SwiftUI

struct LocationDetailViewModel {
    // MARK: - Stored Properties

    let location: Location
    let baseCurrency: Currency
    let localCurrency: Currency

    // MARK: - Initialization

    init(location: Location, baseCurrency: Currency) {
        self.location = location
        self.baseCurrency = baseCurrency
        self.localCurrency = Currency.from(location.localCurrencyCode)
    }
    
    // MARK: - Computed Properties

    var eventHeaderData: EventSummaryData {
        let plannedAmountBase = location.calculatePlannedAmount(asBaseCurrency: true)
        let plannedAmountLocal = location.calculatePlannedAmount(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true)
        let actualAmountLocal = location.calculateActualAmount(asBaseCurrency: false)
        let hasLocalAmounts = localCurrency != baseCurrency && location.rateLocalToBase > 0

        return EventSummaryData(
            status: location.status,
            startDate: location.startDate,
            endDate: location.endDate,
            days: location.durationInDays,
            plannedBaseAmount: plannedAmountBase,
            actualBaseAmount: actualAmountBase,
            baseAmountDifference: plannedAmountBase - actualAmountBase,
            baseCurrency: baseCurrency,
            plannedLocalAmount: hasLocalAmounts ? plannedAmountLocal : nil,
            actualLocalAmount: hasLocalAmounts ? actualAmountLocal : nil,
            localAmountDifference: hasLocalAmounts ? plannedAmountLocal - actualAmountLocal : nil,
            localCurrency: hasLocalAmounts ? localCurrency : nil,
            badgeIcon: Location.badgeIcon,
            badgeColor: Location.badgeColor
        )
    }
    
    // MARK: - Public Methods
    
    func eventHeaderData(expenses: [Expense]) -> EventSummaryData {
        let plannedAmountBase = location.calculatePlannedAmount(asBaseCurrency: true)
        let plannedAmountLocal = location.calculatePlannedAmount(asBaseCurrency: false)
        let actualAmountBase = expenses.reduce(0) { $0 + $1.baseAmount }
        let actualAmountLocal = expenses.reduce(0) { $0 + $1.localAmount }
        let hasLocalAmounts = localCurrency != baseCurrency && location.rateLocalToBase > 0
        
        return EventSummaryData(
            status: location.status,
            startDate: location.startDate,
            endDate: location.endDate,
            days: location.durationInDays,
            plannedBaseAmount: plannedAmountBase,
            actualBaseAmount: actualAmountBase,
            baseAmountDifference: plannedAmountBase - actualAmountBase,
            baseCurrency: baseCurrency,
            plannedLocalAmount: hasLocalAmounts ? plannedAmountLocal : nil,
            actualLocalAmount: hasLocalAmounts ? actualAmountLocal : nil,
            localAmountDifference: hasLocalAmounts ? plannedAmountLocal - actualAmountLocal : nil,
            localCurrency: hasLocalAmounts ? localCurrency : nil,
            badgeIcon: Location.badgeIcon,
            badgeColor: Location.badgeColor
        )
    }
    
    func groupedExpenses(from expenses: [Expense]) -> [(date: Date, expenses: [Expense])] {
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
}
