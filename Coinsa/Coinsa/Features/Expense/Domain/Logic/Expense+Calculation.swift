//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
    // MARK: - Вычисляемые свойства
    
    private var calculationContext: ExpenseCalculationContext {
        ExpenseCalculationContext(
            homeAmount: homeAmount,
            homeCurrency: homeCurrency,
            expenseCurrency: expenseCurrency,
            rateExpenseToHome: rateExpenseToHome,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment
        )
    }
    
    // MARK: - Публичные методы
    
    /// Возвращает сумму в указанной валюте.
    /// - Parameters:
    ///   - currency: Валюта, в которой нужно получить сумму.
    ///   - exchangeRateMode: Режим расчета курса.
    /// - Returns: Сумма в указанной валюте.
    func amount(
        in currency: CurrencyContext,
        using exchangeRateMode: ExchangeRateMode = .effective
    ) -> Double {
        calculationContext.amount(in: currency, using: exchangeRateMode)
    }
    
    /// Возвращает курс обмена между контекстными валютами траты.
    /// - Parameters:
    ///   - baseCurrency: Исходная валюта.
    ///   - quoteCurrency: Целевая валюта.
    ///   - exchangeRateMode: Режим расчета курса.
    /// - Returns: Курс обмена исходной валюты к целевой.
    func exchangeRate(
        from baseCurrency: CurrencyContext,
        to quoteCurrency: CurrencyContext,
        using exchangeRateMode: ExchangeRateMode = .effective
    ) -> Double {
        calculationContext.exchangeRate(from: baseCurrency, to: quoteCurrency, using: exchangeRateMode)
    }
    
    /// Возвращает обратный курс обмена между контекстными валютами траты.
    /// - Parameters:
    ///   - baseCurrency: Исходная валюта.
    ///   - quoteCurrency: Целевая валюта.
    ///   - exchangeRateMode: Режим расчета курса.
    /// - Returns: Курс обмена исходной валюты к целевой.
    func inverseExchangeRate(
        from baseCurrency: CurrencyContext,
        to quoteCurrency: CurrencyContext,
        using exchangeRateMode: ExchangeRateMode = .effective
    ) -> Double {
        calculationContext.inverseExchangeRate(from: baseCurrency, to: quoteCurrency, using: exchangeRateMode)
    }
}
