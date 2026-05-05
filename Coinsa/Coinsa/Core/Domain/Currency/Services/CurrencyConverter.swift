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
    private(set) var localCurrency: Currency
    private(set) var rateLocalToBase: Double
    private(set) var exchangeAdjustment: Double
    
    // MARK: - Вычисляемые свойства
    
    var effectiveRateLocalToBase: Double {
        effectiveRateLocalToBase(useExchangeAdjustment: true)
    }
    
    var isHomeLocation: Bool {
        baseCurrency == localCurrency
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
    ///   - localCurrency: Локальная валюта.
    ///   - rateLocalToBase: Начальный курс. По умолчанию `1`.
    ///   - exchangeAdjustment: Начальная корректировка. По умолчанию `0`.
    init(
        exchangeRateProvider: ExchangeRateProvider,
        baseCurrency: Currency,
        localCurrency: Currency,
        rateLocalToBase: Double = 1,
        exchangeAdjustment: Double = 0
    ) {
        self.exchangeRateManager = ExchangeRateManager(provider: exchangeRateProvider)
        self.baseCurrency = baseCurrency
        self.localCurrency = localCurrency
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustment = exchangeAdjustment
    }
    
    // MARK: - Получение и обновление курса валюты
    
    /// Обновляет основную валюту.
    /// - Parameter newCurrency: Новая основная валюта.
    func updateBaseCurrency(_ newCurrency: Currency) {
        let oldBase = baseCurrency
        baseCurrency = newCurrency
        
        if isHomeLocation {
            exchangeRateManager.cancelRefresh()
            rateLocalToBase = 1
        } else if baseCurrency != oldBase {
            requestRateRefresh()
        }
    }
    
    /// Обновляет локальную валюту.
    /// - Parameters:
    ///   - newCurrency: Новая локлаьная валюта.
    ///   - onCompletion: Замыкание после обновления (опционально).
    func updateLocalCurrency(_ newCurrency: Currency, onCompletion: (() -> Void)? = nil) {
        let oldCurrency = localCurrency
        localCurrency = newCurrency

        if isHomeLocation {
            exchangeRateManager.cancelRefresh()
            rateLocalToBase = 1
            onCompletion?()
        } else if localCurrency != oldCurrency {
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
        rateLocalToBase = newRate
    }
    
    /// Запрашивает обновление курса с сервера.
    /// - Parameter completion: Замыкание после обновления курса (опционально).
    func requestRateRefresh(completion: ((Double) -> Void)? = nil) {
        exchangeRateManager.requestRefresh(
            from: localCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.rateLocalToBase = rate
            completion?(rate)
        }
    }
    
    // MARK: - Конвертация сумм
    
    /// Конвертирует сумму между основной и локальной валютами.
    /// - Parameters:
    ///   - amount: Конвертируемая сумма.
    ///   - source: Исходная валюта.
    ///   - target: Целевая валюта.
    ///   - useExchangeAdjustment: Флаг использования корректировки курса обмена.
    /// - Returns: Сконвертированная сумма.
    func convertAmount(
        _ amount: Double,
        from source: InputCurrency,
        to target: InputCurrency,
        useExchangeAdjustment: Bool = true
    ) -> Double {
        switch (source, target) {
        case (.base, .local):
            convertToLocal(fromBase: amount, useExchangeAdjustment: useExchangeAdjustment)
        case (.local, .base):
            convertToBase(fromLocal: amount, useExchangeAdjustment: useExchangeAdjustment)
        default: amount
        }
    }
    
    /// Конвертирует сумму из основной валюты в локальную.
    /// - Parameter amount: Сумма в основной валюте.
    /// - Returns: Сумма в локальной валюте.
    func convertToBase(fromLocal amount: Double, useExchangeAdjustment: Bool = true) -> Double {
        let effectiveRate = effectiveRateLocalToBase(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount * effectiveRate : 0
    }
    
    /// Конвертирует сумму из локальной валюты в основную.
    /// - Parameter amount: Сумма в локальной валюте.
    /// - Returns: Сумма в основной валюте.
    func convertToLocal(fromBase amount: Double, useExchangeAdjustment: Bool = true) -> Double {
        let effectiveRate = effectiveRateLocalToBase(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount / effectiveRate : 0
    }
    
    // MARK: - Процент корректировки
    
    /// Обновляет процент корректировки курса.
    /// - Parameter newAdjustment: Новое значение.
    func updateExchangeAdjustment(_ newAdjustment: Double) {
        exchangeAdjustment = newAdjustment.nonNegative
    }
    
    // MARK: - Приватные методы
    
    private func effectiveRateLocalToBase(useExchangeAdjustment: Bool) -> Double {
        guard useExchangeAdjustment else { return rateLocalToBase }
        return rateLocalToBase * (1 + (exchangeAdjustment / 100))
    }
}
