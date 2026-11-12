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
    let budgetTitle: LocalizedStringResource
    let budgetHomeAmount: Double
    let expensesHomeAmount: Double
    let homeCurrency: Currency
    let budgetLocationAmount: Double?
    let expensesLocationAmount: Double?
    let locationCurrency: Currency?
    let homeAmountBalance: Double
    let locationAmountBalance: Double?
    
    // MARK: - Инициализация
    
    /// Создает сводные данные события.
    /// - Parameters:
    ///   - badgeProvider: Провайдер бейджа (опционально).
    ///   - dateRangeProvider: Провайдер диапазона дат (опционально).
    ///   - budgetTitle: Заголовок бюджета. По умолчанию «Бюджет».
    ///   - budgetHomeAmount: Cумма бюджета в домашней валюте.
    ///   - expensesHomeAmount: Сумма трат в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - budgetLocationAmount: Сумма бюджета в валюте локации (опционально).
    ///   - expensesLocationAmount: Сумма трат в валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    ///   - homeAmountBalance: Остаток в домашней валюте; по умолчанию бюджет минус отображаемые расходы.
    ///   - locationAmountBalance: Остаток в валюте локации; по умолчанию бюджет минус отображаемые расходы.
    init(
        badgeProvider: TypeBadgeProviding.Type? = nil,
        dateRangeProvider: DateRangeProviding? = nil,
        budgetTitle: LocalizedStringResource = .amountBudget,
        budgetHomeAmount: Double,
        expensesHomeAmount: Double,
        homeCurrency: Currency,
        budgetLocationAmount: Double? = nil,
        expensesLocationAmount: Double? = nil,
        locationCurrency: Currency? = nil,
        homeAmountBalance: Double? = nil,
        locationAmountBalance: Double? = nil
    ) {
        self.badgeProvider = badgeProvider
        self.dateRangeProvider = dateRangeProvider
        self.budgetTitle = budgetTitle
        self.budgetHomeAmount = budgetHomeAmount
        self.expensesHomeAmount = expensesHomeAmount
        self.homeCurrency = homeCurrency
        self.budgetLocationAmount = budgetLocationAmount
        self.expensesLocationAmount = expensesLocationAmount
        self.locationCurrency = locationCurrency
        self.homeAmountBalance = homeAmountBalance ?? (budgetHomeAmount - expensesHomeAmount)
        if let locationAmountBalance {
            self.locationAmountBalance = locationAmountBalance
        } else if let budgetLocationAmount, let expensesLocationAmount {
            self.locationAmountBalance = budgetLocationAmount - expensesLocationAmount
        } else {
            self.locationAmountBalance = nil
        }
    }
}
