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
    ///   - asBaseCurrency: Если `true`, сумма возвращается в основной валюте, иначе в локальной.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Плановая сумма.
    func calculatePlannedAmount(
        asBaseCurrency: Bool = true,
        asDailyAverage: Bool = false,
        using calendar: Calendar = .current
    ) -> Double {
        locations?.reduce(0) {
            $0 + $1.calculatePlannedAmount(
                asBaseCurrency: asBaseCurrency,
                asDailyAverage: asDailyAverage,
                using: calendar
            )
        } ?? 0
    }
    
    /// Рассчитывает плановые суммы по категориям для всех локаций поездки.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, суммы возвращаются в основной валюте, иначе в локальной.
    ///   - withinDateRange: Опциональный диапазон дат для фильтрации.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Словарь из категорий и сумм.
    func calculatePlannedAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil,
        using calendar: Calendar = .current
    ) -> [ExpenseCategory: Double] {
        locations?.reduce(into: [:]) { result, location in
            let locationValues = location.calculatePlannedAmountByCategory(
                asBaseCurrency: asBaseCurrency,
                withinDateRange: withinDateRange,
                using: calendar
            )
            
            for (category, amount) in locationValues {
                result[category, default: 0] += amount
            }
        } ?? [:]
    }
    
    // MARK: - Фактическая сумма
    
    /// Рассчитывает общую фактическую сумму по всем локациям поездки.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, сумма возвращается в основной валюте, иначе в локальной.
    ///   - withinDateRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Фактическая сумма.
    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> Double {
        locations?.reduce(0) {
            $0 + $1.calculateActualAmount(asBaseCurrency: asBaseCurrency, withinDateRange: withinDateRange)
        } ?? 0
    }
    
    /// Рассчитывает фактические суммы по категориям для всех локаций поездки.
    /// - Parameters:
    ///   - asBaseCurrency: Если `true`, суммы возвращаются в основной валюте, иначе в локальной.
    ///   - withinDateRange: Опциональный диапазон дат для фильтрации.
    /// - Returns: Словарь из категорий и сумм.
    func calculateActualAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        locations?.reduce(into: [:]) { result, location in
            let locationValues = location.calculateActualAmountByCategory(
                asBaseCurrency: asBaseCurrency,
                withinDateRange: withinDateRange
            )
            
            for (category, amount) in locationValues {
                result[category, default: 0] += amount
            }
        } ?? [:]
    }
}
