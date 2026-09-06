//
//  ExpenseCalculationContext.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.07.2026.
//

// Структура для хранения данных траты и вычисления сумм.
struct ExpenseCalculationContext {
    // MARK: - Хранимые свойства.
    
    let baseAmount: Double
    let baseCurrency: Currency
    let expenseCurrency: Currency
    let rateExpenseToBase: Double
    let rateExpenseToLocation: Double
    let paymentMethod: PaymentMethod
    let exchangeAdjustment: Double
    
    // MARK: - Приватные вычисляемые свойства
    
    private var adjustedRateExpenseToBase: Double {
        if baseCurrency != expenseCurrency && paymentMethod == .card {
            rateExpenseToBase * (1 + (exchangeAdjustment / 100))
        } else {
            rateExpenseToBase
        }
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
        switch currency {
        case .base: baseAmount
        case .location: baseAmount * exchangeRate(from: .base, to: .location, using: rateMode)
        case .expense: baseAmount * exchangeRate(from: .base, to: .expense, using: rateMode)
        }
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
        guard sourceCurrency != targetCurrency else { return 1 }
        
        let sourceRateToBase = rateToBase(for: sourceCurrency, using: rateMode)
        let targetRateToBase = rateToBase(for: targetCurrency, using: rateMode)
        
        return targetRateToBase > 0 ? sourceRateToBase / targetRateToBase : 0
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
        let rate = exchangeRate(from: sourceCurrency, to: targetCurrency, using: rateMode)
        return rate > 0 ? 1 / rate : 0
    }
    
    // MARK: - Приватные методы
    
    /// Возвращает курс указанного валютного контекста к основной валюте.
    ///   - targetCurrency: Валютный контекст.
    ///   - rateMode: Режим расчета курса.
    private func rateToBase(
        for targetCurrency: CurrencyContext,
        using rateMode: RateMode
    ) -> Double {
        switch targetCurrency {
        case .base: 1
        case .location: rateLocationToBase()
        case .expense: rateExpenseToBase(using: rateMode)
        }
    }
    
    private func rateExpenseToBase(using rateMode: RateMode) -> Double {
        switch rateMode {
        case .effective: adjustedRateExpenseToBase
        case .actual: rateExpenseToBase
        }
    }
    
    private func rateLocationToBase() -> Double {
        rateExpenseToLocation > 0 ? rateExpenseToBase / rateExpenseToLocation : 0
    }
}
