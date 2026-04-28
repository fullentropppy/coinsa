//
//  EventAnalyticsViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.04.2026.
//

import SwiftUI

enum EventAnalyticsMetric: String, CaseIterable, Identifiable {
    case summary
    case plan
    case actual

    var id: String { rawValue }

    var localizedTitle: LocalizedStringResource {
        switch self {
        case .summary: .analyticsSummary
        case .plan: .analyticsPlan
        case .actual: .analyticsActual
        }
    }
}

enum EventAnalyticsSummaryMode: String, CaseIterable, Identifiable {
    case perCategory
    case fromTotal

    var id: String { rawValue }

    var localizedTitle: LocalizedStringResource {
        switch self {
        case .perCategory: .analyticsSummaryPerCategory
        case .fromTotal: .analyticsSummaryFromTotal
        }
    }
}

struct EventAnalyticsCategoryProgressItem: Identifiable {
    let category: ExpenseCategory
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?

    var id: String { category.id }
}

struct EventAnalyticsViewModel {
    // MARK: - Хранимые свойства

    let data: EventCategoryAnalyticsData

    // MARK: - Вычисляемые свойства. Валюта

    var baseCurrency: Currency {
        data.baseCurrency
    }

    var localCurrency: Currency? {
        data.localCurrency
    }

    // MARK: - Вычисляемые свойства. Итоги

    var totalDays: Double {
        Double(data.dateRange.upperBound.days(from: data.dateRange.lowerBound) + 1).rounded()
    }
    
    var remainingDays: Double {
        Double(min(Date().endOfDay, data.dateRange.upperBound.endOfDay).days(from: data.dateRange.lowerBound.startOfDay) + 1).rounded()
    }
    
    var plannedTotalBaseAmount: Double {
        data.plannedAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var actualTotalBaseAmount: Double {
        data.actualAmountByCategory.reduce(0) { $0 + $1.baseAmount }
    }

    var plannedTotalLocalAmount: Double? {
        guard localCurrency != nil else { return nil }
        return data.plannedAmountByCategory.reduce(0) { $0 + ($1.localAmount ?? 0) }
    }

    var actualTotalLocalAmount: Double? {
        guard localCurrency != nil else { return nil }
        return data.actualAmountByCategory.reduce(0) { $0 + ($1.localAmount ?? 0) }
    }

    var dailyBasePlannedAmount: Double {
        plannedTotalBaseAmount / totalDays
    }
    
    var dailyLocalPlannedAmount: Double? {
        if let plannedTotalLocalAmount {
            plannedTotalLocalAmount / totalDays
        } else {
            nil
        }
    }
    
    var dailyBaseActualAmount: Double {
        actualTotalBaseAmount / remainingDays
    }
    
    var dailyLocalActualAmount: Double? {
        if let actualTotalLocalAmount {
            actualTotalLocalAmount / remainingDays
        } else {
            nil
        }
    }
    
    var baseAmountBalance: Double {
        plannedTotalBaseAmount - actualTotalBaseAmount
    }
    
    var localAmountBalance: Double? {
        if let plannedTotalLocalAmount, let actualTotalLocalAmount {
            plannedTotalLocalAmount - actualTotalLocalAmount
        } else {
            nil
        }
    }
    
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

    // MARK: - Вычисляемые свойства. По категориям

    var rawCategoryProgressItems: [EventAnalyticsCategoryProgressItem] {
        let plannedByCategory = Dictionary(uniqueKeysWithValues: data.plannedAmountByCategory.map { ($0.category, $0) })
        let actualByCategory = Dictionary(uniqueKeysWithValues: data.actualAmountByCategory.map { ($0.category, $0) })

        return ExpenseCategory.allCases
            .map { category in
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

    // MARK: - Методы

    func categoryProgressItems(for mode: EventAnalyticsSummaryMode) -> [EventAnalyticsCategoryProgressItem] {
        switch mode {
        case .perCategory: rawCategoryProgressItems
        case .fromTotal: effectiveCategoryProgressItems
        }
    }

    func displayedSlicesSortedByID(for metric: EventAnalyticsMetric) -> [CategoryAnalyticsSlice] {
        slices(for: metric).sorted { $0.category.id > $1.category.id }
    }

    func displayedSlicesSortedByAmount(for metric: EventAnalyticsMetric) -> [CategoryAnalyticsSlice] {
        slices(for: metric).sorted { $0.baseAmount > $1.baseAmount }
    }

    func showsEmptyState(for metric: EventAnalyticsMetric) -> Bool {
        switch metric {
        case .summary: false
        case .plan, .actual: displayedSlicesSortedByID(for: metric).isEmpty
        }
    }

    func shareValue(for slice: CategoryAnalyticsSlice, metric: EventAnalyticsMetric) -> Double {
        let totalBaseAmount = displayedSlicesSortedByID(for: metric).reduce(0) { $0 + $1.baseAmount }
        return totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
    }

    // MARK: - Вспомогательные методы

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
        let globalBaseRemaining = max(plannedTotalBaseAmount - actualTotalBaseAmount, 0)
        let rawBaseRemainders = rawItems.map { max($0.plannedBaseAmount - $0.actualBaseAmount, 0) }
        let totalRawBaseRemaining = rawBaseRemainders.reduce(0, +)

        let globalLocalRemaining: Double? = {
            guard let plannedTotalLocalAmount, let actualTotalLocalAmount else { return nil }
            return max(plannedTotalLocalAmount - actualTotalLocalAmount, 0)
        }()
        let rawLocalRemainders: [Double]? = {
            guard localCurrency != nil else { return nil }
            return rawItems.map { max(($0.plannedLocalAmount ?? 0) - ($0.actualLocalAmount ?? 0), 0) }
        }()
        let totalRawLocalRemaining = rawLocalRemainders?.reduce(0, +) ?? 0

        return rawItems.enumerated().map { index, item in
            var effectivePlannedBaseAmount = item.plannedBaseAmount
            var effectivePlannedLocalAmount = item.plannedLocalAmount
            
            if item.plannedBaseAmount > 0 {
                let baseWeight = totalRawBaseRemaining > 0 ? rawBaseRemainders[index] / totalRawBaseRemaining : 0
                let effectiveBaseRemaining = baseWeight * globalBaseRemaining
                effectivePlannedBaseAmount = item.plannedBaseAmount == 0 ? 0 : item.actualBaseAmount + effectiveBaseRemaining
            }
            
            if let plannedLocalAmount = item.plannedLocalAmount, plannedLocalAmount > 0 {
                effectivePlannedLocalAmount = {
                    guard let globalLocalRemaining, let rawLocalRemainders else { return nil }
                    let localWeight = totalRawLocalRemaining > 0 ? rawLocalRemainders[index] / totalRawLocalRemaining : 0
                    let effectiveLocalRemaining = localWeight * globalLocalRemaining
                    let actualLocalAmount = item.actualLocalAmount ?? 0
                    return actualLocalAmount + effectiveLocalRemaining
                }()
            }

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
