//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    /// Обратный курс (основная к локальной).
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    /// Эффективный курс локальной к основной (с учетом корректировки).
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    /// Эффективный курс основной к локальной (с учетом корректировки).
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    /// Скорректированный курс с учетом процента корректировки.
    private var adjustedRateLocalToBase: Double {
        rateLocalToBase * (1 + (exchangeAdjustment / 100))
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    /// Рассчитывает плановую сумму на сегодня (с учетом уже потраченного).
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, возвращает в основной валюте, иначе в локальной.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Рекомендуемая сумма на сегодня.
    func calculatePlannedAmountForToday(
        asBaseCurrency: Bool = true,
        using calendar: Calendar = .current
    ) -> Double {
        let plannedAmount = calculatePlannedAmount(
            asBaseCurrency: asBaseCurrency,
            asDailyAverage: false,
            using: calendar
        )
        
        if totalDays(using: calendar) == 1 {
            return plannedAmount
        }
        
        let endOfYesterday = Date().yesterday(using: calendar).endOfDay(using: calendar)
        let startRange = min(startDate.startOfDay(using: calendar), endOfYesterday)
        let endRange = max(startRange, endOfYesterday)
        
        let actualAmount = calculateActualAmount(
            asBaseCurrency: asBaseCurrency,
            withinDateRange: startRange...endRange
        )
        
        let remainingDays = remainingDays(on: .now, using: calendar)
        let difference = plannedAmount - actualAmount
        
        return remainingDays == 0 ? difference : max(0, difference / Double(remainingDays + 1))
    }
    
    /// Рассчитывает общую плановую сумму по бюджетам.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, возвращает в основной валюте, иначе в локальной.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Плановая сумма.
    func calculatePlannedAmount(
        asBaseCurrency: Bool = true,
        asDailyAverage: Bool = false,
        using calendar: Calendar = .current
    ) -> Double {
        let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
        let plannedAmount = (budgets?.reduce(0) { $0 + $1.baseAmount } ?? 0) * exchangeRate
        let totalDays = totalDays(using: calendar)
        
        return asDailyAverage ? plannedAmount / Double(totalDays).rounded() : plannedAmount
    }
    
    /// Рассчитывает плановые суммы по категориям.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, возвращает в основной валюте, иначе в локальной.
    ///   - targetRange: Опциональный диапазон дат для фильтрации.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Словарь из категорий и сумм.
    func calculatePlannedAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil,
        using calendar: Calendar = .current
    ) -> [ExpenseCategory: Double] {
        let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
        let periodRatio = plannedAmountRatio(withinDateRange: targetRange, using: calendar)
        
        return ExpenseCategory.allCases.reduce(into: [:]) { result, category in
            let baseAmount = budgetAmount(for: category)
            result[category] = baseAmount * exchangeRate * periodRatio
        }
    }
    
    // MARK: - Публичные методы. Фактическая сумма
    
    /// Рассчитывает общую фактическую сумму по расходам.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, возвращает в основной валюте, иначе в локальной.
    ///   - targetRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Фактическая сумма.
    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> Double {
        expenses?.reduce(0) { result, expense in
            if let targetRange, !targetRange.contains(expense.date) {
                return result
            }
            
            let exchangeRate = asBaseCurrency ? 1 : expense.effectiveRateBaseToLocal
            return result + expense.baseAmount * exchangeRate
        } ?? 0
    }
    
    /// Рассчитывает фактические суммы по категориям.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, возвращает в основной валюте, иначе в локальной.
    ///   - targetRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Словарь из категорий и сумм.
    func calculateActualAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        expenses?.reduce(into: [:]) { result, expense in
            if let targetRange, !targetRange.contains(expense.date) {
                return
            }
            
            let exchangeRate = asBaseCurrency ? 1 : expense.effectiveRateBaseToLocal
            result[expense.category, default: 0] += expense.baseAmount * exchangeRate
        } ?? [:]
    }
    
    // MARK: - Приватные методы
    
    /// Вычисляет долю периода в общей длительности локации.
    /// - Parameters:
    ///   - targetRange: Целевой диапазон дат.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Коэффициент пропорции (0...1).
    private func plannedAmountRatio(
        withinDateRange targetRange: ClosedRange<Date>?,
        using calendar: Calendar = .current
    ) -> Double {
        guard let targetRange else { return 1 }
        
        let normalizedTargetLowerBound = targetRange.lowerBound.startOfDay(using: calendar)
        let normalizedTargetUppedBound = targetRange.upperBound.endOfDay(using: calendar)
        let range = range(using: calendar)
        let overlapStart = max(range.lowerBound, normalizedTargetLowerBound)
        let overlapEnd = min(range.upperBound, normalizedTargetUppedBound)
        
        guard overlapStart <= overlapEnd else { return 0 }
        
        let totalDays = totalDays(using: calendar)
        
        guard totalDays > 0 else { return 0 }
        
        let overlapDays = overlapEnd
            .startOfDay(using: calendar)
            .days(from: overlapStart.startOfDay, using: calendar) + 1
        
        return min(1, max(0, Double(overlapDays) / Double(totalDays)))
    }
}
