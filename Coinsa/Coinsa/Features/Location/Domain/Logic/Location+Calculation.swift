//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    /// Эффективный курс локальной валюты к базовой (с учетом корректировки)
    var effectiveRateLocationToBase: Double {
        rateLocationToBase * (1 + (exchangeAdjustment / 100))
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    /// Рассчитывает плановую сумму на сегодня (с учетом уже потраченного)
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - rateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`
    /// - Returns: Рекомендуемая сумма на сегодня
    func calculateBudgetAmountForToday(
        in currency: CurrencyContext = .base,
        using rateMode: RateMode = .actual,
        calendar: Calendar = .utc
    ) -> Double {
        let budgetAmount = calculateBudgetAmount(
            in: currency,
            asDailyAverage: false,
            using: rateMode,
            calendar: calendar
        )
        
        if totalDays(using: calendar) == 1 {
            return budgetAmount
        }
        
        let today = PlainDate.today
        let endOfYesterday = today.adding(days: -1).endOfDay
        let startRange = min(startPlainDate.startOfDay, endOfYesterday)
        let endRange = max(startRange, endOfYesterday)
        
        let expensesAmount = calculateExpensesAmount(
            in: currency,
            using: rateMode,
            withinDateRange: startRange...endRange
        )
        
        let remainingDays = remainingDays(on: today, using: calendar)
        let difference = budgetAmount - expensesAmount
        
        return remainingDays == 0 ? difference : max(0, difference / Double(remainingDays + 1))
    }
    
    /// Рассчитывает общую плановую сумму по бюджету
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день
    ///   - rateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`
    /// - Returns: Плановая сумма
    func calculateBudgetAmount(
        in currency: CurrencyContext = .base,
        asDailyAverage: Bool = false,
        using rateMode: RateMode = .actual,
        calendar: Calendar = .utc
    ) -> Double {
        let exchangeRate = exchangeRateBaseToCurrency(currency, using: rateMode)
        let budgetAmount = budget * exchangeRate
        let totalDays = totalDays(using: calendar)
        
        return asDailyAverage ? budgetAmount / Double(totalDays).rounded() : budgetAmount
    }
    
    // MARK: - Публичные методы. Фактическая сумма
    
    /// Рассчитывает общую фактическую сумму по расходам
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - rateMode: Режим расчета курса
    ///   - targetRange: Опциональный диапазон дат для фильтрации
    /// - Returns: Фактическая сумма
    func calculateExpensesAmount(
        in currency: CurrencyContext = .base,
        using rateMode: RateMode = .effective,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> Double {
        guard canAggregateAmounts(in: currency) else { return 0 }
        
        return expenses?.reduce(0) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return result
            }
            return result + expense.amount(in: currency, using: rateMode)
        } ?? 0
    }
    
    /// Рассчитывает фактические суммы по категориям
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - rateMode: Режим расчета курса
    ///   - targetRange: Опциональный диапазон дат для фильтрации
    /// - Returns: Словарь из категорий и сумм
    func calculateExpensesAmountByCategory(
        in currency: CurrencyContext = .base,
        using rateMode: RateMode = .effective,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        guard canAggregateAmounts(in: currency) else { return [:] }
        
        return expenses?.reduce(into: [:]) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return
            }
            result[expense.category, default: 0] += expense.amount(in: currency, using: rateMode)
        } ?? [:]
    }
    
    // MARK: - Приватные методы
    
    /// Возвращает курс основной валюты к запрошенному контексту.
    private func exchangeRateBaseToCurrency(_ currency: CurrencyContext, using rateMode: RateMode) -> Double {
        switch currency {
        case .base: 1
        case .location: exchangeRateBaseToLocation(using: rateMode)
        case .expense: 0
        }
    }
    
    /// Возвращает курс основной валюты к валюте локации.
    private func exchangeRateBaseToLocation(using rateMode: RateMode) -> Double {
        switch rateMode {
        case .effective: effectiveRateLocationToBase > 0 ? 1 / effectiveRateLocationToBase : 0
        case .actual: rateLocationToBase > 0 ? 1 / rateLocationToBase : 0
        }
    }
    
    private func canAggregateAmounts(in currency: CurrencyContext) -> Bool {
        currency != .expense
    }
    
    /// Вычисляет долю периода в общей длительности локации.
    /// - Parameters:
    ///   - targetRange: Целевой диапазон дат.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Коэффициент пропорции (0...1).
    private func budgetAmountRatio(
        withinDateRange targetRange: ClosedRange<Date>?,
        using calendar: Calendar = .utc
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
            .days(from: overlapStart.startOfDay(using: calendar), using: calendar) + 1
        
        return min(1, max(0, Double(overlapDays) / Double(totalDays)))
    }
}
