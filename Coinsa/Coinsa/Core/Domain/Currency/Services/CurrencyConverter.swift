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
    private(set) var locationCurrency: Currency
    private(set) var rateLocationToBase: Double
    private(set) var exchangeAdjustment: Double
    
    // MARK: - Вычисляемые свойства
    
    var effectiveRateLocationToBase: Double {
        effectiveRateLocationToBase(useExchangeAdjustment: true)
    }
    
    var isHomeLocation: Bool {
        baseCurrency == locationCurrency
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
    ///   - locationCurrency: Локальная валюта.
    ///   - rateLocationToBase: Начальный курс. По умолчанию `1`.
    ///   - exchangeAdjustment: Начальная корректировка. По умолчанию `0`.
    init(
        exchangeRateProvider: ExchangeRateProvider,
        baseCurrency: Currency,
        locationCurrency: Currency,
        rateLocationToBase: Double = 1,
        exchangeAdjustment: Double = 0
    ) {
        self.exchangeRateManager = ExchangeRateManager(provider: exchangeRateProvider)
        self.baseCurrency = baseCurrency
        self.locationCurrency = locationCurrency
        self.rateLocationToBase = rateLocationToBase
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
            rateLocationToBase = 1
        } else if baseCurrency != oldBase {
            requestRateRefresh()
        }
    }
    
    /// Обновляет локальную валюту.
    /// - Parameters:
    ///   - newCurrency: Новая локлаьная валюта.
    ///   - onCompletion: Замыкание после обновления (опционально).
    func updateLocalCurrency(_ newCurrency: Currency, onCompletion: (() -> Void)? = nil) {
        let oldCurrency = locationCurrency
        locationCurrency = newCurrency

        if isHomeLocation {
            exchangeRateManager.cancelRefresh()
            rateLocationToBase = 1
            onCompletion?()
        } else if locationCurrency != oldCurrency {
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
        rateLocationToBase = newRate
    }
    
    /// Запрашивает обновление курса с сервера.
    /// - Parameter completion: Замыкание после обновления курса (опционально).
    func requestRateRefresh(completion: ((Double) -> Void)? = nil) {
        exchangeRateManager.requestRefresh(
            from: locationCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.rateLocationToBase = rate
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
        let effectiveRate = effectiveRateLocationToBase(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount * effectiveRate : 0
    }
    
    /// Конвертирует сумму из локальной валюты в основную.
    /// - Parameter amount: Сумма в локальной валюте.
    /// - Returns: Сумма в основной валюте.
    func convertToLocal(fromBase amount: Double, useExchangeAdjustment: Bool = true) -> Double {
        let effectiveRate = effectiveRateLocationToBase(useExchangeAdjustment: useExchangeAdjustment)
        return effectiveRate > 0 ? amount / effectiveRate : 0
    }
    
    // MARK: - Процент корректировки
    
    /// Обновляет процент корректировки курса.
    /// - Parameter newAdjustment: Новое значение.
    func updateExchangeAdjustment(_ newAdjustment: Double) {
        exchangeAdjustment = newAdjustment.nonNegative
    }
    
    // MARK: - Приватные методы
    
    private func effectiveRateLocationToBase(useExchangeAdjustment: Bool) -> Double {
        guard useExchangeAdjustment else { return rateLocationToBase }
        return rateLocationToBase * (1 + (exchangeAdjustment / 100))
    }
}
