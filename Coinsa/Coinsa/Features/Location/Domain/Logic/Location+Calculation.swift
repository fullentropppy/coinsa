//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    var currencyConversion: LocationCurrencyConversion {
        LocationCurrencyConversion(rateLocationToHome: homeCurrency == locationCurrency ? 1 : rateLocationToHome)
    }

    /// Рассчитывает остаток в домашней валюте и переводит его по сохраненному курсу локации.
    /// - Parameter currency: Валютный контекст результата: `.home` или `.location`.
    /// - Returns: Домашний остаток или его эквивалент без повторного применения корректировки курса.
    func calculateBudgetBalance(in currency: CurrencyContext = .home) -> Double {
        convertHomeAmount(budget - calculateExpensesAmount(), to: currency)
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    /// Рассчитывает лимит сегодняшнего дня с учетом трат других дней и исключенных дневных трат.
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`
    /// - Returns: Рекомендуемая сумма на сегодня
    func calculateBudgetAmountForToday(
        in currency: CurrencyContext = .home,
        calendar: Calendar = .utc
    ) -> Double {
        let today = PlainDate.today
        let todayRange = today.startOfDay...today.endOfDay
        let expensesAmount = expenses?.reduce(0) { result, expense in
            guard expense.isExcludedFromDailySpending
                    || !todayRange.contains(expense.civilDateTime.storedDate) else { return result }
            return result + expense.homeAmount
        } ?? 0
        
        return calculateDailyBudgetAmount(
            on: today,
            in: currency,
            reservedHomeExpensesAmount: expensesAmount,
            calendar: calendar
        )
    }

    /// Распределяет свободный бюджет на оставшиеся дни; обычные траты выбранного дня не меняют лимит.
    /// - Parameters:
    ///   - day: Календарный день, для которого определяется число оставшихся дней локации.
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - reservedHomeExpensesAmount: Все траты других дней и исключенные траты выбранного дня в домашней валюте.
    ///   - calendar: Календарь расчета бюджета; оставшиеся дни определяются по календарным датам в UTC.
    /// - Returns: Неотрицательный лимит дня; после окончания локации и при некорректных суммах возвращается 0.
    func calculateDailyBudgetAmount(
        on day: PlainDate,
        in currency: CurrencyContext = .home,
        reservedHomeExpensesAmount: Double,
        calendar: Calendar = .utc
    ) -> Double {
        guard totalDays > 0, day <= endPlainDate,
              budget.isFinite, reservedHomeExpensesAmount.isFinite else { return 0 }

        let remainingDays = endPlainDate.days(from: max(day, startPlainDate)) + 1
        let difference = budget - reservedHomeExpensesAmount
        
        return convertHomeAmount(max(0, difference / Double(remainingDays)), to: currency)
    }
    
    /// Рассчитывает общую плановую сумму по бюджету
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`
    /// - Returns: Плановая сумма
    func calculateBudgetAmount(
        in currency: CurrencyContext = .home,
        asDailyAverage: Bool = false,
        calendar: Calendar = .utc
    ) -> Double {
        let totalDays = totalDays
        let homeAmount = asDailyAverage ? budget / Double(totalDays).rounded() : budget

        return convertHomeAmount(homeAmount, to: currency)
    }
    
    // MARK: - Публичные методы. Фактическая сумма
    
    /// Суммирует домашние суммы трат и переводит итог по сохраненному курсу локации.
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - targetRange: Включенный диапазон гражданских дат трат; при `nil` учитывается вся история.
    /// - Returns: Домашняя сумма трат или ее эквивалент в валюте локации.
    func calculateExpensesAmount(
        in currency: CurrencyContext = .home,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> Double {
        guard canAggregateAmounts(in: currency) else { return 0 }
        
        let homeAmount = expenses?.reduce(0) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return result
            }
            return result + expense.homeAmount
        } ?? 0

        return convertHomeAmount(homeAmount, to: currency)
    }
    
    /// Суммирует домашние суммы категорий и переводит итоги по сохраненному курсу локации.
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - targetRange: Включенный диапазон гражданских дат трат; при `nil` учитывается вся история.
    /// - Returns: Домашние суммы категорий или их эквиваленты в валюте локации.
    func calculateExpensesAmountByCategory(
        in currency: CurrencyContext = .home,
        withinDateRange targetRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        guard canAggregateAmounts(in: currency) else { return [:] }
        
        let homeAmounts: [ExpenseCategory: Double] = expenses?.reduce(into: [:]) { result, expense in
            if let targetRange, !targetRange.contains(expense.civilDateTime.storedDate) {
                return
            }
            result[expense.category, default: 0] += expense.homeAmount
        } ?? [:]

        return homeAmounts.mapValues { convertHomeAmount($0, to: currency) }
    }
    
    // MARK: - Пересчет итогов
    
    /// Переводит домашний итог по сохраненному курсу локации без корректировки.
    /// - Parameters:
    ///   - amount: Сумма в домашней валюте.
    ///   - currency: Целевой валютный контекст; `.expense` не поддерживается для итогов локации.
    /// - Returns: Домашняя сумма или ее эквивалент; для `.expense` возвращает 0.
    func convertHomeAmount(_ amount: Double, to currency: CurrencyContext) -> Double {
        switch currency {
        case .home: amount
        case .location: currencyConversion.locationAmount(forHomeAmount: amount)
        case .expense: 0
        }
    }

    // MARK: - Приватные методы
    
    /// Проверяет, можно ли суммировать расходы локации в выбранном валютном контексте.
    /// - Parameter currency: Валютный контекст суммы.
    /// - Returns: `true` для `.home` и `.location`; `.expense` может объединять разные валюты и не поддерживается.
    private func canAggregateAmounts(in currency: CurrencyContext) -> Bool {
        currency != .expense
    }
}
