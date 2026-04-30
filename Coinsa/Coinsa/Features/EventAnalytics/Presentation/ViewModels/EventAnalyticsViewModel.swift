//
//  EventAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.04.2026.
//

import SwiftUI

struct EventAnalyticsViewModel {
    // MARK: - Зависимости

    let data: EventCategoryAnalyticsData

    // MARK: - Хранимые свойства. Валюта

    var baseCurrency: Currency {
        data.baseCurrency
    }

    var localCurrency: Currency? {
        data.localCurrency
    }

    // MARK: - Хранимые свойства. Дни
    
    var startDate: Date {
        data.dateRange.lowerBound.startOfDay
    }
    
    var endDate: Date {
        data.dateRange.upperBound.endOfDay
    }
    
    var totalDays: Double {
        let daysInt = endDate.days(from: startDate) + 1
        return Double(daysInt).rounded()
    }
    
    var remainingDays: Double {
        let daysInt = min(Date().endOfDay, endDate).days(from: startDate) + 1
        return Double(daysInt).rounded()
    }
    
    // MARK: - Хранимые свойства. Сумма в основной валюте
    
    var plannedTotalBaseAmount: Double {
        data.plannedAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var actualTotalBaseAmount: Double {
        data.actualAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var dailyBasePlannedAmount: Double {
        plannedTotalBaseAmount / totalDays
    }
    
    var dailyBaseActualAmount: Double {
        actualTotalBaseAmount / remainingDays
    }
    
    var baseAmountBalance: Double {
        plannedTotalBaseAmount - actualTotalBaseAmount
    }
    
    // MARK: - Хранимые свойства. Сумма в локальной валюте
    
    var plannedTotalLocalAmount: Double? {
        if localCurrency != nil {
            data.plannedAmountByCategory.reduce(0) { $0 + ($1.localAmount ?? 0) }
        } else {
            nil
        }
    }

    var actualTotalLocalAmount: Double? {
        if localCurrency != nil {
            data.actualAmountByCategory.reduce(0) { $0 + ($1.localAmount ?? 0) }
        } else {
            nil
        }
    }
    
    var dailyLocalPlannedAmount: Double? {
        if let plannedTotalLocalAmount {
            plannedTotalLocalAmount / totalDays
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
        if let plannedTotalLocalAmount, let actualTotalLocalAmount {
            plannedTotalLocalAmount - actualTotalLocalAmount
        } else {
            nil
        }
    }
    
    // MARK: - Хранимые свойства. Общие данные
    
    var eventSummaryData: EventSummaryData {
        EventSummaryData(
            plannedBaseAmount: plannedTotalBaseAmount,
            actualBaseAmount: actualTotalBaseAmount,
            baseCurrency: baseCurrency,
            plannedLocalAmount: plannedTotalLocalAmount,
            actualLocalAmount: actualTotalLocalAmount,
            localCurrency: localCurrency
        )
    }

    var rawCategoryProgressItems: [EventAnalyticsCategoryProgressItem] {
        let plannedByCategory = Dictionary(uniqueKeysWithValues: data.plannedAmountByCategory.map { ($0.category, $0) })
        let actualByCategory = Dictionary(uniqueKeysWithValues: data.actualAmountByCategory.map { ($0.category, $0) })

        return ExpenseCategory.allCases.map { category in
            let plannedSlice = plannedByCategory[category]
            let actualSlice = actualByCategory[category]
            
            return EventAnalyticsCategoryProgressItem(
                category: category,
                plannedBaseAmount: plannedSlice?.baseAmount ?? 0,
                actualBaseAmount: actualSlice?.baseAmount ?? 0,
                plannedLocalAmount: plannedSlice?.localAmount,
                actualLocalAmount: actualSlice?.localAmount
            )
        }
    }

    // MARK: - Публичные методы

    func displayedSlicesSortedByID(for metric: EventAnalyticsMetric) -> [CategoryAnalyticsSlice] {
        slices(for: metric).sorted { $0.category.id > $1.category.id }
    }

    func displayedSlicesSortedByAmount(for metric: EventAnalyticsMetric) -> [CategoryAnalyticsSlice] {
        slices(for: metric).sorted { $0.baseAmount > $1.baseAmount }
    }

    func categoryProgressItems(for mode: EventAnalyticsSummaryMode) -> [EventAnalyticsCategoryProgressItem] {
        switch mode {
        case .perCategory: rawCategoryProgressItems
        case .fromTotal: effectiveCategoryProgressItems
        }
    }
    
    func hasAnalytics(for metric: EventAnalyticsMetric) -> Bool {
        switch metric {
        case .summary: true
        case .plan, .actual: !displayedSlicesSortedByID(for: metric).isEmpty
        }
    }

    func shareValue(for slice: CategoryAnalyticsSlice, metric: EventAnalyticsMetric) -> Double {
        let totalBaseAmount = displayedSlicesSortedByID(for: metric).reduce(0) { $0 + $1.baseAmount }
        return totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
    }

    // MARK: - Приватные методы

    private func slices(for metric: EventAnalyticsMetric) -> [CategoryAnalyticsSlice] {
        let slices: [CategoryAnalyticsSlice]

        switch metric {
        case .summary, .plan:
            slices = data.plannedAmountByCategory
        case .actual:
            slices = data.actualAmountByCategory
        }

        return slices.contains { $0.baseAmount > 0 } ? slices : []
    }

    private var effectiveCategoryProgressItems: [EventAnalyticsCategoryProgressItem] {
        let rawItems = rawCategoryProgressItems
        let globalBaseRemaining = max(0, plannedTotalBaseAmount - actualTotalBaseAmount)
        let rawBaseRemainders = rawItems.map { max(0, $0.plannedBaseAmount - $0.actualBaseAmount) }
        let totalRawBaseRemaining = rawBaseRemainders.reduce(0, +)

        let globalLocalRemaining: Double? = {
            if let plannedTotalLocalAmount, let actualTotalLocalAmount {
                max(0, plannedTotalLocalAmount - actualTotalLocalAmount)
            } else {
                nil
            }
        }()
        
        let rawLocalRemainders: [Double]? = {
            if localCurrency != nil {
                rawItems.map { max(($0.plannedLocalAmount ?? 0) - ($0.actualLocalAmount ?? 0), 0) }
            } else {
                nil
            }
        }()
        
        let totalRawLocalRemaining = rawLocalRemainders?.reduce(0, +) ?? 0
        
        return rawItems.enumerated().map { index, item in
            var effectivePlannedBaseAmount = item.plannedBaseAmount
            var effectivePlannedLocalAmount = item.plannedLocalAmount
            
            let baseWeight = totalRawBaseRemaining > 0 ? rawBaseRemainders[index] / totalRawBaseRemaining : 0
            let effectiveBaseRemaining = baseWeight * globalBaseRemaining
            effectivePlannedBaseAmount = item.actualBaseAmount + effectiveBaseRemaining
            
            effectivePlannedLocalAmount = {
                guard let globalLocalRemaining, let rawLocalRemainders else { return nil }
                let localWeight = totalRawLocalRemaining > 0 ? rawLocalRemainders[index] / totalRawLocalRemaining : 0
                let effectiveLocalRemaining = localWeight * globalLocalRemaining
                let actualLocalAmount = item.actualLocalAmount ?? 0
                return actualLocalAmount + effectiveLocalRemaining
            }()
            
            return EventAnalyticsCategoryProgressItem(
                category: item.category,
                plannedBaseAmount: effectivePlannedBaseAmount,
                actualBaseAmount: item.actualBaseAmount,
                plannedLocalAmount: effectivePlannedLocalAmount,
                actualLocalAmount: item.actualLocalAmount
            )
        }
    }
}
