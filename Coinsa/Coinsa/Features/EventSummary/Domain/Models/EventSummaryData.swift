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
    let budgetHomeAmount: Double
    let expensesHomeAmount: Double
    let homeCurrency: Currency
    let budgetLocationAmount: Double?
    let expensesLocationAmount: Double?
    let locationCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает сводные данные события.
    /// - Parameters:
    ///   - badgeProvider: Провайдер бейджа (опционально).
    ///   - dateRangeProvider: Провайдер диапазона дат (опционально).
    ///   - budgetHomeAmount: Cумма бюджета в домашней валюте.
    ///   - expensesHomeAmount: Сумма трат в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - budgetLocationAmount: Сумма бюджета в валюте локации (опционально).
    ///   - expensesLocationAmount: Сумма трат в валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    init(
        badgeProvider: TypeBadgeProviding.Type? = nil,
        dateRangeProvider: DateRangeProviding? = nil,
        budgetHomeAmount: Double,
        expensesHomeAmount: Double,
        homeCurrency: Currency,
        budgetLocationAmount: Double? = nil,
        expensesLocationAmount: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.badgeProvider = badgeProvider
        self.dateRangeProvider = dateRangeProvider
        self.budgetHomeAmount = budgetHomeAmount
        self.expensesHomeAmount = expensesHomeAmount
        self.homeCurrency = homeCurrency
        self.budgetLocationAmount = budgetLocationAmount
        self.expensesLocationAmount = expensesLocationAmount
        self.locationCurrency = locationCurrency
    }
}
