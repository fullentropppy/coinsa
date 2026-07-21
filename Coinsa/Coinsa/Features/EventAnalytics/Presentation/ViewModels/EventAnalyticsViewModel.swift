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
        data.dateRange.lowerBound.startOfDay(using: .utc)
    }
    
    var endDate: Date {
        data.dateRange.upperBound.endOfDay(using: .utc)
    }
    
    var totalDays: Double {
        let daysInt = endDate.days(from: startDate, using: .utc) + 1
        return Double(daysInt).rounded()
    }
    
    var remainingDays: Double {
        let today = PlainDate.today.endOfDay
        let daysInt = min(today, endDate).days(from: startDate, using: .utc) + 1
        return Double(daysInt).rounded()
    }
    
    // MARK: - Хранимые свойства. Сумма в основной валюте

    var expensesTotalBaseAmount: Double {
        data.expensesAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var dailyBaseBudgetAmount: Double {
        data.baseBudget / totalDays
    }
    
    var dailyBaseExpensesAmount: Double {
        expensesTotalBaseAmount / remainingDays
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
    
    var dailyLocalBudgetAmount: Double? {
        if let localBudget = data.localBudget {
            localBudget / totalDays
        } else {
            nil
        }
    }
    
    var dailyLocalExpensesAmount: Double? {
        if let expensesTotalLocationAmount {
            expensesTotalLocationAmount / remainingDays
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
    
    // MARK: - Публичные методы

    func displayedSlicesSortedByID(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.category.id > $1.category.id }
    }

    func displayedSlicesSortedByAmount(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        slices(for: metric).sorted { $0.baseAmount > $1.baseAmount }
    }
    
    func hasAnalytics(for metric: EventAnalyticsMetric) -> Bool {
        switch metric {
        case .summary: true
        case .actual: !displayedSlicesSortedByID(for: metric).isEmpty
        }
    }

    func shareValue(for slice: ExpenseAnalyticsSlice, metric: EventAnalyticsMetric) -> Double {
        let totalBaseAmount = displayedSlicesSortedByID(for: metric).reduce(0) { $0 + $1.baseAmount }
        return totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
    }

    // MARK: - Приватные методы

    private func slices(for metric: EventAnalyticsMetric) -> [ExpenseAnalyticsSlice] {
        let slices: [ExpenseAnalyticsSlice]

        switch metric {
        case .summary:
            slices = data.expensesAmountByCategory /// Замениить
        case .actual:
            slices = data.expensesAmountByCategory
        }

        return slices.contains { $0.baseAmount > 0 } ? slices : []
    }
}
