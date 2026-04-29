//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    private var adjustedRateLocalToBase: Double {
        rateLocalToBase * (1 + (exchangeAdjustment / 100))
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    func calculatePlannedAmountForToday(asBaseCurrency: Bool = true) -> Double {
        let plannedAmount = calculatePlannedAmount(asBaseCurrency: asBaseCurrency, asDailyAverage: false)

        if totalDays == 1 {
            return plannedAmount
        }
        
        let endOfYesterday = Date().yesterday.endOfDay
        let startRange = min(startDate, endOfYesterday)
        let endRange = max(startRange, endOfYesterday)
        
        let actualAmount = calculateActualAmount(
            asBaseCurrency: asBaseCurrency,
            withinDateRange: startRange...endRange
        )
        
        let difference = plannedAmount - actualAmount
        return remainingDays == 0 ? difference : max(0, difference / Double(remainingDays + 1))
    }

    func calculatePlannedAmount(
        asBaseCurrency: Bool = true,
        asDailyAverage: Bool = false
    ) -> Double {
        let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
        let plannedAmount = budgets.reduce(0) { $0 + $1.baseAmount } * exchangeRate
        return asDailyAverage ? plannedAmount / Double(totalDays).rounded() : plannedAmount
    }
 
    func calculatePlannedAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
        let periodRatio = plannedAmountRatio(withinDateRange: targetRange)

        return ExpenseCategory.allCases.reduce(into: [:]) { result, category in
            let baseAmount = budgetAmount(for: category)
            result[category] = baseAmount * exchangeRate * periodRatio
        }
    }
    
    // MARK: - Публичные методы. Фактическая сумма
    
    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> Double {
        expenses.reduce(0) { result, expense in
            if let targetRange, !targetRange.contains(expense.date) {
                return result
            }
            
            let exchangeRate = asBaseCurrency ? 1 : expense.effectiveRateBaseToLocal
            return result + expense.baseAmount * exchangeRate
        }
    }

    func calculateActualAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        expenses.reduce(into: [:]) { result, expense in
            if let targetRange, !targetRange.contains(expense.date) {
                return
            }

            let exchangeRate = asBaseCurrency ? 1 : expense.effectiveRateBaseToLocal
            result[expense.category, default: 0] += expense.baseAmount * exchangeRate
        }
    }

    // MARK: - Приватные методы

    private func plannedAmountRatio(withinDateRange targetRange: ClosedRange<Date>?) -> Double {
        guard let targetRange else { return 1 }

        let normalizedTargetRange = targetRange.lowerBound.startOfDay...targetRange.upperBound.endOfDay
        let overlapStart = max(range.lowerBound, normalizedTargetRange.lowerBound)
        let overlapEnd = min(range.upperBound, normalizedTargetRange.upperBound)

        guard overlapStart <= overlapEnd else { return 0 }

        let overlapDays = overlapEnd.startOfDay.days(from: overlapStart.startOfDay) + 1
        guard totalDays > 0 else { return 0 }

        return min(1, max(0, Double(overlapDays) / Double(totalDays)))
    }
}
