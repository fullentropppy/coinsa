//
//  CurrencyConverter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Observation

/// Конвертер валют для работы с курсами и корректировками.
@MainActor
@Observable
final class CurrencyConverter {
    // MARK: - Хранимые свойства
    
    private let exchangeRateManager: ExchangeRateManager
    private(set) var baseCurrency: Currency
    private(set) var quoteCurrency: Currency
    private(set) var rateBaseToQuote: Double
    private(set) var exchangeAdjustment: Double
    
    // MARK: - Вычисляемые свойства
    
    var effectiveRateBaseToQuote: Double {
        effectiveRateBaseToQuote(useExchangeAdjustment: true)
    }
    
    var isSameCurrency: Bool {
        baseCurrency == quoteCurrency
    }
    
    var isRateLoading: Bool {
        exchangeRateManager.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { exchangeRateManager.rateLoadingError }
        set { exchangeRateManager.rateLoadingError = newValue }
    }
    
    // MARK: - Инициализация
    
    /// Создает конвертер валют.
    /// - Parameters:
    ///   - exchangeRateProvider: Провайдер курсов обмена.
    ///   - baseCurrency: Основная валюта.
    ///   - quoteCurrency: Котируемая валюта.
    ///   - rateBaseToQuote: Начальный курс. По умолчанию `1`.
    ///   - exchangeAdjustment: Начальная корректировка. По умолчанию `0`.
    init(
        exchangeRateProvider: ExchangeRateProvider,
        baseCurrency: Currency,
        quoteCurrency: Currency,
        rateBaseToQuote: Double = 1,
        exchangeAdjustment: Double = 0
    ) {
        self.exchangeRateManager = ExchangeRateManager(provider: exchangeRateProvider)
        self.baseCurrency = baseCurrency
        self.quoteCurrency = quoteCurrency
        self.rateBaseToQuote = rateBaseToQuote
        self.exchangeAdjustment = exchangeAdjustment
    }
    
    // MARK: - Получение и обновление курса валюты
    
    /// Обновляет основную валюту.
    /// - Parameter newCurrency: Новая основная валюта.
    func updatebaseCurrency(_ newCurrency: Currency) {
        let oldCurrency = baseCurrency
        baseCurrency = newCurrency
        
        if isSameCurrency {
            exchangeRateManager.cancelRefresh()
            rateBaseToQuote = 1
        } else if baseCurrency != oldCurrency {
            requestRateRefresh()
        }
    }
    
    /// Обновляет котируемую валюту.
    /// - Parameters:
    ///   - newCurrency: Новая котируемая валюта.
    ///   - onCompletion: Замыкание после обновления (опционально).
    func updateQuoteCurrency(_ newCurrency: Currency, onCompletion: (() -> Void)? = nil) {
        let oldCurrency = quoteCurrency
        quoteCurrency = newCurrency

        if isSameCurrency {
            exchangeRateManager.cancelRefresh()
            rateBaseToQuote = 1
            onCompletion?()
        } else if quoteCurrency != oldCurrency {
            requestRateRefresh { _ in
                onCompletion?()
            }
        } else {
            onCompletion?()
        }
    }
    
    /// Обновляет курс вручную.
    /// - Parameter newRate: Новый курс.
    func updateRate(_ newRate: Double) {
        rateBaseToQuote = newRate
    }
    
    /// Запрашивает обновление курса с сервера.
    /// - Parameter completion: Замыкание после обновления курса (опционально).
    func requestRateRefresh(completion: ((Double) -> Void)? = nil) {
        exchangeRateManager.requestRefresh(
            from: quoteCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.rateBaseToQuote = rate
            completion?(rate)
        }
    }
    
    // MARK: - Конвертация сумм
    
    /// Конвертирует сумму между основной и котируемой валютами.
    /// - Parameters:
    ///   - amount: Конвертируемая сумма.
    ///   - baseCurrency: Основная валюта.
    ///   - quoteCurrency: Котируемая валюта.
    ///   - useExchangeAdjustment: Флаг использования корректировки курса обмена.
    /// - Returns: Сконвертированная сумма.
    func convertAmount(
        _ amount: Double,
        from baseCurrency: CurrencyContext,
        to quoteCurrency: CurrencyContext,
        useExchangeAdjustment: Bool = true
    ) -> Double {
        if baseCurrency == .base {
            convertToQuote(fromBase: amount, useExchangeAdjustment: useExchangeAdjustment)
        } else {
            convertToBase(fromQuote: amount, useExchangeAdjustment: useExchangeAdjustment)
        }
    }
    
    /// Конвертирует сумму из основной валюты в в котируемую.
    /// - Parameter amount: Сумма в основной валюте.
    /// - Returns: Сумма в котируемой валюте.
    func convertToBase(fromQuote amount: Double, useExchangeAdjustment: Bool = true) -> Double {
        let effectiveRate = effectiveRateBaseToQuote(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount * effectiveRate : 0
    }
    
    /// Конвертирует сумму из котируемой валюты в основную.
    /// - Parameter amount: Сумма в котируемой валюте.
    /// - Returns: Сумма в основной валюте.
    func convertToQuote(fromBase amount: Double, useExchangeAdjustment: Bool = true) -> Double {
        let effectiveRate = effectiveRateBaseToQuote(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount / effectiveRate : 0
    }
    
    // MARK: - Процент корректировки
    
    /// Обновляет процент корректировки курса.
    /// - Parameter newAdjustment: Новое значение.
    func updateExchangeAdjustment(_ newAdjustment: Double) {
        exchangeAdjustment = newAdjustment.nonNegative
    }
    
    // MARK: - Приватные методы
    
    private func effectiveRateBaseToQuote(useExchangeAdjustment: Bool) -> Double {
        guard useExchangeAdjustment else { return rateBaseToQuote }
        return rateBaseToQuote * (1 + (exchangeAdjustment / 100))
    }
}
