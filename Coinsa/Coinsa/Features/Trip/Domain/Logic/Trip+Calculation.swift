//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    // MARK: - Плановая сумма
    
    /// Рассчитывает общую плановую сумму по всем локациям поездки.
    /// - Parameters:
    ///   - inBaseCurrency: Если `true`, сумма возвращается в основной валюте, иначе в локальной.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Плановая сумма.
    func calculateBudgetAmount(
        inBaseCurrency: Bool = true,
        asDailyAverage: Bool = false,
        using calendar: Calendar = .utc
    ) -> Double {
        locations?.reduce(0) {
            $0 + $1.calculateBudgetAmount(
                in: inBaseCurrency ? CurrencyContext.base : CurrencyContext.location,
                asDailyAverage: asDailyAverage,
                calendar: calendar
            )
        } ?? 0
    }
    
    // MARK: - Фактическая сумма
    
    /// Рассчитывает общую фактическую сумму по всем локациям поездки.
    /// - Parameters:
    ///   - inBaseCurrency: Если `true`, сумма возвращается в основной валюте, иначе в локальной.
    ///   - withinDateRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Фактическая сумма.
    func calculateExpensesAmount(
        inBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> Double {
        locations?.reduce(0) {
            $0 + $1.calculateExpensesAmount(
                in: inBaseCurrency ? CurrencyContext.base : CurrencyContext.location,
                withinDateRange: withinDateRange
            )
        } ?? 0
    }
    
    /// Рассчитывает фактические суммы по категориям для всех локаций поездки.
    /// - Parameters:
    ///   - inBaseCurrency: Если `true`, суммы возвращаются в основной валюте, иначе в локальной.
    ///   - withinDateRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Словарь из категорий и сумм.
    func calculateExpensesAmountByCategory(
        inBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        locations?.reduce(into: [:]) { result, location in
            let locationValues = location.calculateExpensesAmountByCategory(
                in: inBaseCurrency ? CurrencyContext.base : CurrencyContext.location,
                withinDateRange: withinDateRange
            )
            
            for (category, amount) in locationValues {
                result[category, default: 0] += amount
            }
        } ?? [:]
    }
}
