//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
    // MARK: - Вычисляемые свойства.
    
    private var calculationContext: ExpenseCalculationContext {
        ExpenseCalculationContext(
            baseAmount: baseAmount,
            baseCurrency: baseCurrency,
            expenseCurrency: expenseCurrency,
            rateExpenseToBase: rateExpenseToBase,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment
        )
    }
    
    // MARK: - Публичные методы
    
    /// Возвращает сумму в указанной валюте.
    /// - Parameters:
    ///   - currency: Валюта, в которой нужно получить сумму.
    ///   - rateMode: Режим расчета курса.
    /// - Returns: Сумма в указанной валюте.
    func amount(
        in currency: CurrencyContext,
        using rateMode: RateMode = .effective
    ) -> Double {
        calculationContext.amount(in: currency, using: rateMode)
    }
    
    /// Возвращает курс обмена между контекстными валютами траты.
    /// - Parameters:
    ///   - sourceCurrency: Исходная валюта.
    ///   - targetCurrency: Целевая валюта.
    ///   - rateMode: Режим расчета курса.
    /// - Returns: Курс обмена исходной валюты к целевой.
    func exchangeRate(
        from sourceCurrency: CurrencyContext,
        to targetCurrency: CurrencyContext,
        using rateMode: RateMode = .effective
    ) -> Double {
        calculationContext.exchangeRate(from: sourceCurrency, to: targetCurrency, using: rateMode)
    }
    
    /// Возвращает обратный курс обмена между контекстными валютами траты.
    /// - Parameters:
    ///   - sourceCurrency: Исходная валюта.
    ///   - targetCurrency: Целевая валюта.
    ///   - rateMode: Режим расчета курса.
    /// - Returns: Курс обмена исходной валюты к целевой.
    func inverseExchangeRate(
        from sourceCurrency: CurrencyContext,
        to targetCurrency: CurrencyContext,
        using rateMode: RateMode = .effective
    ) -> Double {
        calculationContext.inverseExchangeRate(from: sourceCurrency, to: targetCurrency, using: rateMode)
    }
}
