//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    /// Эффективный курс валюты локации к основной (с учетом корректировки)
    var effectiveRateLocationToHome: Double {
        rateLocationToHome * (1 + (exchangeAdjustment / 100))
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    /// Рассчитывает плановую сумму на сегодня (с учетом уже потраченного)
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`
    /// - Returns: Рекомендуемая сумма на сегодня
    func calculateBudgetAmountForToday(
        in currency: CurrencyContext = .home,
        using exchangeRateMode: ExchangeRateMode = .actual,
        calendar: Calendar = .utc
    ) -> Double {
        let budgetAmount = calculateBudgetAmount(
            in: currency,
            asDailyAverage: false,
            using: exchangeRateMode,
            calendar: calendar
        )
        
        if totalDays == 1 {
            return budgetAmount
        }
        
        let today = PlainDate.today
        let endOfYesterday = today.adding(days: -1).endOfDay
        let startRange = min(startPlainDate.startOfDay, endOfYesterday)
        let endRange = max(startRange, endOfYesterday)
        
        let expensesAmount = calculateExpensesAmount(
            in: currency,
            using: exchangeRateMode,
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
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`
    /// - Returns: Плановая сумма
    func calculateBudgetAmount(
        in currency: CurrencyContext = .home,
        asDailyAverage: Bool = false,
        using exchangeRateMode: ExchangeRateMode = .actual,
        calendar: Calendar = .utc
    ) -> Double {
        let exchangeRate = exchangeRateHomeToTarget(currency, using: exchangeRateMode)
        let budgetAmount = budget * exchangeRate
        let totalDays = totalDays
        
        return asDailyAverage ? budgetAmount / Double(totalDays).rounded() : budgetAmount
    }
    
    // MARK: - Публичные методы. Фактическая сумма
    
    /// Рассчитывает общую фактическую сумму по расходам
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса
    ///   - targetRange: Опциональный диапазон дат для фильтрации
    /// - Returns: Фактическая сумма
    func calculateExpensesAmount(
        in currency: CurrencyContext = .home,
        using exchangeRateMode: ExchangeRateMode = .effective,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> Double {
        guard canAggregateAmounts(in: currency) else { return 0 }
        
        return expenses?.reduce(0) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return result
            }
            return result + expense.amount(in: currency, using: exchangeRateMode)
        } ?? 0
    }
    
    /// Рассчитывает фактические суммы по категориям
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.base` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса
    ///   - targetRange: Опциональный диапазон дат для фильтрации
    /// - Returns: Словарь из категорий и сумм
    func calculateExpensesAmountByCategory(
        in currency: CurrencyContext = .home,
        using exchangeRateMode: ExchangeRateMode = .effective,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        guard canAggregateAmounts(in: currency) else { return [:] }
        
        return expenses?.reduce(into: [:]) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return
            }
            result[expense.category, default: 0] += expense.amount(in: currency, using: exchangeRateMode)
        } ?? [:]
    }
    
    // MARK: - Приватные методы
    
    /// Возвращает курс домашней валюты к запрошенному контексту.
    private func exchangeRateHomeToTarget(_ currency: CurrencyContext, using exchangeRateMode: ExchangeRateMode) -> Double {
        switch currency {
        case .home: 1
        case .location: exchangeRateHomeToLocation(using: exchangeRateMode)
        case .expense: 0
        }
    }
    
    /// Возвращает курс домашней валюты к валюте локации.
    private func exchangeRateHomeToLocation(using exchangeRateMode: ExchangeRateMode) -> Double {
        switch exchangeRateMode {
        case .effective: effectiveRateLocationToHome > 0 ? 1 / effectiveRateLocationToHome : 0
        case .actual: rateLocationToHome > 0 ? 1 / rateLocationToHome : 0
        }
    }
    
    private func canAggregateAmounts(in currency: CurrencyContext) -> Bool {
        currency != .expense
    }
}
