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
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let baseCurrency: Currency
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?
    let localCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает сводные данные события.
    /// - Parameters:
    ///   - badgeProvider: Провайдер бейджа (опционально).
    ///   - dateRangeProvider: Провайдер диапазона дат (опционально).
    ///   - plannedBaseAmount: Плановая сумма в основной валюте.
    ///   - actualBaseAmount: Фактическая сумма в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - plannedLocalAmount: Плановая сумма в локальной валюте (опционально).
    ///   - actualLocalAmount: Фактическая сумма в локальной валюте (опционально).
    ///   - localCurrency: Локальная валюта (опционально).
    init(
        badgeProvider: TypeBadgeProviding.Type? = nil,
        dateRangeProvider: DateRangeProviding? = nil,
        plannedBaseAmount: Double,
        actualBaseAmount: Double,
        baseCurrency: Currency,
        plannedLocalAmount: Double? = nil,
        actualLocalAmount: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.badgeProvider = badgeProvider
        self.dateRangeProvider = dateRangeProvider
        self.plannedBaseAmount = plannedBaseAmount
        self.actualBaseAmount = actualBaseAmount
        self.baseCurrency = baseCurrency
        self.plannedLocalAmount = plannedLocalAmount
        self.actualLocalAmount = actualLocalAmount
        self.localCurrency = localCurrency
    }
}
