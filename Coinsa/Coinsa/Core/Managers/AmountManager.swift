//
//  AmountManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Observation

/// Менеджер для управления суммами в основной и котируемой валютах с автоматической конвертацией.
@MainActor
@Observable
final class AmountManager {
    // MARK: - Хранимые свойства
    
    private let converter: CurrencyConverter
    
    // MARK: - Вычисляемые свойства
    
    private(set) var baseAmount: Double
    private(set) var quoteAmount: Double
    
    // MARK: - Инициализация
    
    /// Создает менеджер сумм.
    /// - Parameters:
    ///   - converter: Конвертер валют.
    ///   - baseAmount: Начальная сумма в основной валюте. По умолчанию `0`.
    ///   - quoteAmount: Начальная сумма в котируемой валюте. По умолчанию `0`.
    init(converter: CurrencyConverter, baseAmount: Double = 0, quoteAmount: Double = 0) {
        self.converter = converter
        self.baseAmount = baseAmount
        self.quoteAmount = quoteAmount
    }
    
    // MARK: - Публичные методы
    
    /// Возвращает сумму в указанной валюте.
    /// - Parameter currencySide: Валюта.
    /// - Returns: Сумма в запрошенной валюте.
    func amount(for currencySide: CurrencySide) -> Double {
        switch currencySide {
        case .base: baseAmount
        case .quote: quoteAmount
        }
    }
    
    /// Обновляет сумму в указанной валюте, автоматически пересчитывая значение в другой валюте.
    /// - Parameters:
    ///   - newValue: Новое значение суммы.
    ///   - currencySide: Валюта, в которой задается новое значение.
    func updateAmount(_ newValue: Double, for currencySide: CurrencySide, useExchangeAdjustment: Bool = true) {
        switch currencySide {
        case .base:
            baseAmount = newValue
            quoteAmount = converter.convertToQuote(
                fromBase: newValue,
                useExchangeAdjustment: useExchangeAdjustment
            )
        case .quote:
            quoteAmount = newValue
            baseAmount = converter.convertToBase(
                fromQuote: newValue,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
    }
    
    /// Обновляет только сумму в основной валюте (пересчитывает котируемую).
    /// - Parameter newValue: Новое значение в основной валюте.
    func updateBaseAmount(_ newValue: Double, useExchangeAdjustment: Bool = true) {
        baseAmount = newValue
        quoteAmount = converter.convertToQuote(fromBase: newValue, useExchangeAdjustment: useExchangeAdjustment)
    }
    
    /// Обновляет только сумму в котируемой валюте (пересчитывает основную).
    /// - Parameter newValue: Новое значение в котируемой валюте.
    func updateQuoteAmount(_ newValue: Double, useExchangeAdjustment: Bool = true) {
        quoteAmount = newValue
        baseAmount = converter.convertToBase(fromQuote: newValue, useExchangeAdjustment: useExchangeAdjustment)
    }
    
    /// Обновляет суммы после изменения курса обмена.
    /// - Parameter currencySide: Валюта, значение которой остается неизменным при пересчете.
    func updateFromRateChange(for currencySide: CurrencySide, useExchangeAdjustment: Bool = true) {
        let currentAmount = amount(for: currencySide)
        updateAmount(currentAmount, for: currencySide, useExchangeAdjustment: useExchangeAdjustment)
    }
    
    /// Сбрасывает обе суммы в ноль.
    func reset() {
        baseAmount = 0
        quoteAmount = 0
    }
}
