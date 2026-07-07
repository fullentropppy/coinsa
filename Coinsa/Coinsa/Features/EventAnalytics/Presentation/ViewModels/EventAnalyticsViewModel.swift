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

    var actualTotalBaseAmount: Double {
        data.actualAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var dailyBasePlannedAmount: Double {
        data.baseBudget / totalDays
    }
    
    var dailyBaseActualAmount: Double {
        actualTotalBaseAmount / remainingDays
    }
    
    var baseAmountBalance: Double {
        data.baseBudget - actualTotalBaseAmount
    }
    
    // MARK: - Хранимые свойства. Сумма в локальной валюте
    
    var actualTotalLocalAmount: Double? {
        if locationCurrency != nil {
            data.actualAmountByCategory.reduce(0) { $0 + ($1.localAmount ?? 0) }
        } else {
            nil
        }
    }
    
    var dailyLocalPlannedAmount: Double? {
        if let localBudget = data.localBudget {
            localBudget / totalDays
        } else {
            nil
        }
    }
    
    var dailyLocalActualAmount: Double? {
        if let actualTotalLocalAmount {
            actualTotalLocalAmount / remainingDays
        } else {
            nil
        }
    }
    
    var localAmountBalance: Double? {
        if let localBudget = data.localBudget, let actualTotalLocalAmount {
            localBudget - actualTotalLocalAmount
        } else {
            nil
        }
    }
    
    // MARK: - Хранимые свойства. Общие данные
    
    var eventSummaryData: EventSummaryData {
        EventSummaryData(
            plannedBaseAmount: data.baseBudget,
            actualBaseAmount: actualTotalBaseAmount,
            baseCurrency: baseCurrency,
            plannedLocalAmount: data.localBudget,
            actualLocalAmount: actualTotalLocalAmount,
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
            slices = data.actualAmountByCategory /// Замениить
        case .actual:
            slices = data.actualAmountByCategory
        }

        return slices.contains { $0.baseAmount > 0 } ? slices : []
    }
}
