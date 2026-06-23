//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
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
        case .base:
            return 1
        case .location:
            return rateLocationToBase(using: rateMode)
        case .expense:
            return rateExpenseToBase(using: rateMode)
        }
    }
    
    private func rateExpenseToBase(using rateMode: RateMode) -> Double {
        switch rateMode {
        case .effective:
            return adjustedRateExpenseToBase
        case .actual:
            return rateExpenseToBase
        }
    }
    
    private func rateLocationToBase(using rateMode: RateMode) -> Double {
        guard rateExpenseToLocation > 0 else { return 0 }
        return rateExpenseToBase(using: rateMode) / rateExpenseToLocation
    }
    
    // MARK: - Приватные свойства
    
    private var adjustedRateExpenseToBase: Double {
        if baseCurrency != expenseCurrency && paymentMethod == .card {
            return rateExpenseToBase * (1 + (exchangeAdjustment / 100))
        } else {
            return rateExpenseToBase
        }
    }
}
