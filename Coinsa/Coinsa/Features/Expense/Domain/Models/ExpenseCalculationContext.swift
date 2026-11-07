//
//  ExpenseCalculationContext.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.07.2026.
//

/// Структура для хранения данных траты и вычисления сумм.
struct ExpenseCalculationContext {
    // MARK: - Хранимые свойства.
    
    let homeAmount: Double
    let homeCurrency: Currency
    let expenseCurrency: Currency
    let rateExpenseToHome: Double
    let rateExpenseToLocation: Double
    let paymentMethod: PaymentMethod
    let exchangeAdjustment: Double
    
    // MARK: - Приватные вычисляемые свойства
    
    private var adjustedRateExpenseToHome: Double {
        if homeCurrency != expenseCurrency && paymentMethod == .card {
            rateExpenseToHome * (1 + (exchangeAdjustment / 100))
        } else {
            rateExpenseToHome
        }
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
        switch currency {
        case .home: homeAmount
        case .location: homeAmount * exchangeRate(from: .home, to: .location, using: exchangeRateMode)
        case .expense: homeAmount * exchangeRate(from: .home, to: .expense, using: exchangeRateMode)
        }
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
        guard baseCurrency != quoteCurrency else { return 1 }
        
        let sourceRateToBase = rateToBase(for: baseCurrency, using: exchangeRateMode)
        let quoteRateToBase = rateToBase(for: quoteCurrency, using: exchangeRateMode)
        
        return quoteRateToBase > 0 ? sourceRateToBase / quoteRateToBase : 0
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
        let rate = exchangeRate(from: baseCurrency, to: quoteCurrency, using: exchangeRateMode)
        return rate > 0 ? 1 / rate : 0
    }
    
    // MARK: - Приватные методы
    
    /// Возвращает курс указанного валютного контекста к домашней валюте.
    ///   - quoteCurrency: Валютный контекст.
    ///   - exchangeRateMode: Режим расчета курса.
    private func rateToBase(
        for quoteCurrency: CurrencyContext,
        using exchangeRateMode: ExchangeRateMode
    ) -> Double {
        switch quoteCurrency {
        case .home: 1
        case .location: rateLocationToHome()
        case .expense: rateExpenseToHome(using: exchangeRateMode)
        }
    }
    
    private func rateExpenseToHome(using exchangeRateMode: ExchangeRateMode) -> Double {
        switch exchangeRateMode {
        case .effective: adjustedRateExpenseToHome
        case .actual: rateExpenseToHome
        }
    }
    
    private func rateLocationToHome() -> Double {
        rateExpenseToLocation > 0 ? rateExpenseToHome / rateExpenseToLocation : 0
    }
}
