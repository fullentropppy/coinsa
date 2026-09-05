//
//  EventSummaryData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

/// Структура для хранения сводных данных события.
struct EventSummaryData {
    // MARK: - Свойства
    
    let badgeProvider: TypeBadgeProviding.Type?
    let dateRangeProvider: DateRangeProviding?
    let budgetBaseAmount: Double
    let expensesBaseAmount: Double
    let baseCurrency: Currency
    let budgetLocationAmount: Double?
    let expensesLocationAmount: Double?
    let locationCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает сводные данные события.
    /// - Parameters:
    ///   - badgeProvider: Провайдер бейджа (опционально).
    ///   - dateRangeProvider: Провайдер диапазона дат (опционально).
    ///   - budgetBaseAmount: Cумма бюджета в основной валюте.
    ///   - expensesBaseAmount: Сумма трат в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - budgetLocationAmount: Сумма бюджета в валюте локации (опционально).
    ///   - expensesLocationAmount: Сумма трат в валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    init(
        badgeProvider: TypeBadgeProviding.Type? = nil,
        dateRangeProvider: DateRangeProviding? = nil,
        budgetBaseAmount: Double,
        expensesBaseAmount: Double,
        baseCurrency: Currency,
        budgetLocationAmount: Double? = nil,
        expensesLocationAmount: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.badgeProvider = badgeProvider
        self.dateRangeProvider = dateRangeProvider
        self.budgetBaseAmount = budgetBaseAmount
        self.expensesBaseAmount = expensesBaseAmount
        self.baseCurrency = baseCurrency
        self.budgetLocationAmount = budgetLocationAmount
        self.expensesLocationAmount = expensesLocationAmount
        self.locationCurrency = locationCurrency
    }
}
