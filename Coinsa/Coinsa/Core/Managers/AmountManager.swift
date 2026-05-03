//
//  AmountManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Observation

/// Менеджер для управления суммами в основной и локальных валютах с автоматической конвертацией.
@MainActor
@Observable
final class AmountManager {
    // MARK: - Свойства
    
    private let converter: CurrencyConverter
    
    private(set) var baseAmount: Double
    private(set) var localAmount: Double
    
    // MARK: - Инициализация
    
    /// Создает менеджер сумм.
    /// - Parameters:
    ///   - converter: Конвертер валют.
    ///   - baseAmount: Начальная сумма в основной валюте. По умолчанию `0`.
    ///   - localAmount: Начальная сумма в локальной валюте. По умолчанию `0`.
    init(converter: CurrencyConverter, baseAmount: Double = 0, localAmount: Double = 0) {
        self.converter = converter
        self.baseAmount = baseAmount
        self.localAmount = localAmount
    }
    
    // MARK: - Публичные методы
    
    /// Возвращает сумму в указанной валюте.
    /// - Parameter inputCurrency: Валюта.
    /// - Returns: Сумма в запрошенной валюте.
    func amount(for inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: baseAmount
        case .local: localAmount
        }
    }
    
    /// Обновляет сумму в указанной валюте, автоматически пересчитывая значение в другой валюте.
    /// - Parameters:
    ///   - newValue: Новое значение суммы.
    ///   - inputCurrency: Валюта, в которой задается новое значение.
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            baseAmount = newValue
            localAmount = converter.convertToLocal(fromBase: newValue)
        case .local:
            localAmount = newValue
            baseAmount = converter.convertToBase(fromLocal: newValue)
        }
    }
    
    /// Обновляет только сумму в основной валюте (пересчитывает локальную).
    /// - Parameter newValue: Новое значение в основной валюте.
    func updateBaseAmount(_ newValue: Double) {
        baseAmount = newValue
        localAmount = converter.convertToLocal(fromBase: newValue)
    }
    
    /// Обновляет только сумму в локальной валюте (пересчитывает основную).
    /// - Parameter newValue: Новое значение в локальной валюте.
    func updateLocalAmount(_ newValue: Double) {
        localAmount = newValue
        baseAmount = converter.convertToBase(fromLocal: newValue)
    }
    
    /// Обновляет суммы после изменения курса обмена.
    /// - Parameter inputCurrency: Валюта, значение которой остается неизменным при пересчете.
    func updateFromRateChange(inputCurrency: InputCurrency) {
        let currentAmount = amount(for: inputCurrency)
        updateAmount(currentAmount, for: inputCurrency)
    }
    
    /// Сбрасывает обе суммы в ноль.
    func reset() {
        baseAmount = 0
        localAmount = 0
    }
}
