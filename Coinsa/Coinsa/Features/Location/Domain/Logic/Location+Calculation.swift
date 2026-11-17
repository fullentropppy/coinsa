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

    /// Возвращает остаток всего бюджета в тех же режимах курса, что и сводка локации.
    /// - Parameter currency: Валютный контекст результата: `.home` или `.location`.
    /// - Returns: Бюджет без корректировки курса за вычетом расходов с их сохраненными курсами.
    func calculateBudgetBalance(in currency: CurrencyContext = .home) -> Double {
        calculateBudgetAmount(in: currency) - calculateExpensesAmount(in: currency)
    }
    
    // MARK: - Публичные методы. Плановая сумма
    
    /// Рассчитывает лимит сегодняшнего дня с учетом всех записанных трат других дней.
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`
    /// - Returns: Рекомендуемая сумма на сегодня
    func calculateBudgetAmountForToday(
        in currency: CurrencyContext = .home,
        using exchangeRateMode: ExchangeRateMode = .actual,
        calendar: Calendar = .utc
    ) -> Double {
        let today = PlainDate.today
        let todayRange = today.startOfDay...today.endOfDay
        let expensesAmount = expenses?.reduce(0) { result, expense in
            guard !todayRange.contains(expense.civilDateTime.storedDate) else { return result }
            return result + expense.amount(in: currency, using: exchangeRateMode)
        } ?? 0
        
        return calculateDailyBudgetAmount(
            on: today,
            in: currency,
            using: exchangeRateMode,
            expensesOutsideDay: expensesAmount,
            calendar: calendar
        )
    }

    /// Распределяет свободный бюджет на оставшиеся дни, сохраняя лимит при добавлении трат выбранного дня.
    /// - Parameters:
    ///   - day: Календарный день, для которого определяется число оставшихся дней локации.
    ///   - currency: Валютный контекст бюджета и трат других дней. Поддерживаются `.home` и `.location`.
    ///   - exchangeRateMode: Режим конвертации бюджета; должен совпадать с режимом подсчета трат других дней. По умолчанию `.actual`.
    ///   - expensesOutsideDay: Все записанные траты других дней в выбранной валюте и режиме курса, включая предоплаты и записи с будущей датой.
    ///   - calendar: Календарь расчета бюджета; оставшиеся дни определяются по календарным датам в UTC.
    /// - Returns: Неотрицательный лимит дня; после окончания локации и при некорректных суммах возвращается 0.
    func calculateDailyBudgetAmount(
        on day: PlainDate,
        in currency: CurrencyContext = .home,
        using exchangeRateMode: ExchangeRateMode = .actual,
        expensesOutsideDay: Double,
        calendar: Calendar = .utc
    ) -> Double {
        let budgetAmount = calculateBudgetAmount(in: currency, using: exchangeRateMode, calendar: calendar)

        guard totalDays > 0, day <= endPlainDate,
              budgetAmount.isFinite, expensesOutsideDay.isFinite else { return 0 }

        let remainingDays = endPlainDate.days(from: max(day, startPlainDate)) + 1
        let difference = budgetAmount - expensesOutsideDay
        
        return max(0, difference / Double(remainingDays))
    }
    
    /// Рассчитывает общую плановую сумму по бюджету
    /// - Parameters:
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - asDailyAverage: Если `true`, возвращает среднюю сумму в день
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.actual`
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`
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
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.effective`.
    ///   - targetRange: Включенный диапазон гражданских дат трат; при `nil` учитывается вся история.
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
    ///   - currency: Валютный контекст результата. Поддерживаются `.home` и `.location`.
    ///   - exchangeRateMode: Режим расчета курса. По умолчанию `.effective`.
    ///   - targetRange: Включенный диапазон гражданских дат трат; при `nil` учитывается вся история.
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
    /// - Parameters:
    ///   - currency: Целевой валютный контекст. Контекст `.expense` не поддерживается для бюджета локации.
    ///   - exchangeRateMode: Режим расчета курса с корректировкой или без нее.
    /// - Returns: Количество единиц целевой валюты за единицу домашней; для `.expense` возвращает 0.
    private func exchangeRateHomeToTarget(_ currency: CurrencyContext, using exchangeRateMode: ExchangeRateMode) -> Double {
        switch currency {
        case .home: 1
        case .location: exchangeRateHomeToLocation(using: exchangeRateMode)
        case .expense: 0
        }
    }
    
    /// Возвращает курс домашней валюты к валюте локации.
    /// - Parameter exchangeRateMode: Режим расчета курса с корректировкой или без нее.
    /// - Returns: Обратный курс локации; при неположительном исходном курсе возвращает 0.
    private func exchangeRateHomeToLocation(using exchangeRateMode: ExchangeRateMode) -> Double {
        switch exchangeRateMode {
        case .effective: effectiveRateLocationToHome > 0 ? 1 / effectiveRateLocationToHome : 0
        case .actual: rateLocationToHome > 0 ? 1 / rateLocationToHome : 0
        }
    }
    
    /// Проверяет, можно ли суммировать расходы локации в выбранном валютном контексте.
    /// - Parameter currency: Валютный контекст суммы.
    /// - Returns: `true` для `.home` и `.location`; `.expense` может объединять разные валюты и не поддерживается.
    private func canAggregateAmounts(in currency: CurrencyContext) -> Bool {
        currency != .expense
    }
}
